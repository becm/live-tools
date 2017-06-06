#!/bin/sh
# live-tools/mklive.sh: update/create live media

[ `id -u` -ne 0 ] && asroot="sudo"

# print error message
error () {
    printf "${@} \n" 1>&2
}

# mount first partition of image file
mklive_mount () {
    mount -o offset=1048576 "${1}" "${2}"
}

# exclude packages in desktop install
mklive_filter_packages () {
    grep -Ev 'casper|cryptsetup|debian-installer|discover|dmraid|icu|rdate|reiser|ubiquity|user-setup' "${1}"
}

# update root filesystem
mklive_update () {
    ${asroot} cp -aL /etc/resolv.conf "${1}/etc/resolv.conf"
    ${asroot} mount -t devpts devpts "${1}/dev/pts"
    ${asroot} chroot "${1}" << EOF || return $?
apt-get update
apt-get -y safe-upgrade
apt-get clean
EOF
    ${asroot} umount "${1}/dev/pts"
}

# remove apt cache
mklive_clean_apt () {
    ${asroot} rm -f \
"${1}/var/cache/apt/pkgcache.bin" \
"${1}/var/cache/apt/srcpkgcache.bin" \
"${1}/var/cache/apt/archives/partial/"* \
"${1}/var/lib/aptitude/pkgstates.old" \
"${1}/var/lib/apt/lists/"*_Sources \
"${1}/var/lib/apt/lists/"*_Packages \
"${1}/var/lib/apt/lists/"*_Translation-de \
"${1}/var/lib/apt/lists/"*_Translation-en \
"${1}/var/lib/apt/lists/partial/"*
}
# remove history
mklive_clean_hist () {
    ${asroot} rm -f \
"${1}/var/cache/debconf/"*.dat-old \
"${1}/var/lib/dpkg/"*-old \
"${1}/var/backups/"*.gz \
"${1}/var/log/"*.gz \
"${1}/var/log/upstart/"*.gz
}

# create live files
mklive_create () {
    local root=${1}
    local dest=${2}
    [ -z "${root}" ] && error "missing chroot directory" && return 1
    [ -n "${dest}" ] || dest="."
# get package selections
    ${asroot} chroot "${root}" dpkg-query -W --showformat='${Package} ${Version}\n' > "${dest}/filesystem.manifest" || return 1
    mklive_filter_packages "${dest}/filesystem.manifest" > "${dest}/filesystem.manifest-desktop"
# clear some files
    mklive_clean_apt "${root}"
    mklive_clean_hist "${root}"
    ${asroot} rm -f "${root}/etc/udev/rules.d/"*persistent*.rules
# calculate unpacked size
    printf $(${asroot} du -sx --block-size=1 "${root}" | cut -f1) > "${dest}/filesystem.size" || return $?
# update kernel and initrd
    ${asroot} cp -L --preserve=mode,timestamps "${root}/vmlinuz" "${root}/initrd.img" "${dest}"
# build squash filesystem
    ${asroot} mksquashfs "${root}" "${dest}/filesystem.squashfs" \
        -comp xz -noappend -wildcards \
        -e 'boot/grub' -e 'boot/initrd.*' \
        -e 'initrd.img' \
        -e 'tmp/*' -e 'var/tmp/*' \
        || return $?
    ${asroot} chmod 644 "${dest}/filesystem.squashfs"
}

# create single partition
mklive_part () {
    ${asroot} fdisk ${1} > /dev/null << EOF
o
n
p
1


t
c
w
EOF
}

# change file system label
mklive_label () {
    case `$asroot blkid -o value -s TYPE "$1"` in
        vfat)  local label=fatlabel;;
        exfat) local label=exfatlabel;;
        ntfs)  local label=ntfslabel;;
        *) error 'unsupported file system'; return 1;;
    esac
    ${asroot} "${label}" "${@}"
}

# install grub on device
mklive_grub () {
    [ -z "${1}" ] && error "missing system directory" && return 1
    [ -z "${2}" ] && error "missing target device" && return 1
    ${asroot} dd "if=${2}/grub/boot.img" "of=${1}" bs=446 count=1 && \
    ${asroot} dd "if=${2}/grub/core.img" "of=${1}" bs=512 seek=1
}

# copy live files
mklive_copy () {
    [ $# -lt 2 ] && return 2
# make target directory
    mkdir -p "${2}" || return $?
# copy new files
    printf '%s' 'copying live files... '
    rsync --modify-window=2 -crtL "${1}/*" "${2}" || return $?
    printf '%s\n' 'finished'
}

# live media creation
mklive_install () {
# default settings
    local source="/home/live"
    local mpoint="/mnt"
    local sysdir=".sys"
# overwrite from args
    [ $# -lt 1 ] && return 2
    [ -n "${2}" ] && source="${2}"
    [ -n "${3}" ] && mpoint="${3}"
    [ -n "${4}" ] && sysdir="${4}"
# copy live files
    ${asroot} mount "${1}1" "${mpoint}" || return $?
    mkdir -p "/${mpoint}/${sysdir}" || return $?
    mklive_copy "${source}" "/${mpoint}/${sysdir}" || return $?
# set target directory filesystem flags
    local attr="`which fatattr`"
    if [ -n "$attr" ]; then \
        printf '%s' 'hide system directory... '
        if "$attr" +hs "/${mpoint}/${sysdir}"; then
            printf '%s\n' 'done'
        else
            printf '%s\n' 'failed'
        fi
    fi
# boot sector
    printf '%s' 'write boot sector... '
    mklive_grub "${1}"
    ${asroot} umount "${mpoint}"
    printf '%s\n' 'finished'
}

# print available script operations
mklive_usage () {
    printf "${1} usage:\n"
    local prog="`basename ${1}`"
    printf '  %s %s\n' "${prog}" 'new     <dev>'
    printf '  %s %s\n' "${prog}" 'mount   <image> <root>'
    printf '  %s %s\n' "${prog}" 'label   <partition>'
    printf '  %s %s\n' "${prog}" 'create  <root> <dir>'
    printf '  %s %s\n' "${prog}" 'install <dev> [<dir>] [<mountpoint>]'
    printf '  %s %s\n' "${prog}" 'update  <sysroot>'
}

# script command selection when called
[ -n "$-" ] || {
    case "${1}" in
        mount)   mklive_mount "${2}" "${3}";;
        update)  mklive_update "${2}";;
        new)     mklive_part "${2}" && mkfs.vfat -n LIVE "${2}";;
        create)  shift; mklive_create  "${@}";;
        label)   shift; mklive_label   "${@}";;
        install) shift; mklive_install "${@}";;
        '') mklive_usage "${0}";;
        *)  mklive_usage "${0}"; return 1;;
    esac
    return $?
}
