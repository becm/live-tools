#!/bin/sh
# live-tools/qemu.sh: very simple qemu wrapper

# initialize used variables
image="discard=unmap,detect-zeroes=unmap,if=virtio"
unset args

# process argument flags
while getopts 'SRs:' opt; do
    case $opt in
      # select qemu interface
      S) args="${args} -nographic"
         ;;
      # select image format
      R) image="format=raw,${image}"
         ;;
      # add shared folder
      s) args="${args} -fsdev local,security_model=none,id=qshare,path=${OPTARG}"
         args="${args} -device virtio-9p-pci,fsdev=qshare,mount_tag=share"
         ;;
      # bad command argument
      \?)
         printf '%s: %s\n' 'error' 'bad argument' 1>&2;
         exit 1
         ;;
    esac
done

# consume flags
shift $((OPTIND-1))

# disk image check
[ -n "${1}" -a -r "${1}" ] || {
    printf "%s: %s\n" "${0}" 'need disk image' 1>&2
    exit 1
}
image="${image},file=${1}"
shift

# start VM instance
exec qemu-system-x86_64 -enable-kvm -boot order=c -m 1G -drive "${image}" ${args} "$@"
