#!/bin/sh
# live-tools/qemu.sh: very simple qemu wrapper

# select qemu interface
unset mode
[ "${1}" = "-S" ] && { mode='-nographic'; shift; }

# disk image setup
[ -n "${1}" -a -r "${1}" ] || {
    printf "%s: %s\n" "${0}" 'need disk image' 1>&2
    exit 1
}
image="file=${1},discard=unmap,detect-zeroes=unmap,if=virtio"
shift

# add shared folder
unset share
[ -n "${1}" ] && {
    [ ! "${1}" = "--" ] && {
        share="-fsdev local,id=qshare,path=${1},security_model=none -device virtio-9p-pci,fsdev=qshare,mount_tag=share"
    }
    shift
}

# start VM instance
exec qemu-system-x86_64 -enable-kvm -boot order=c -m 1G -drive "${image}" $share $mode "$@"
