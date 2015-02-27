#!/bin/bash
# very simple qemu wrapper

unset serial

if [ "${1}" == "-S" ]; then
  serial='-nographic'
  shift
fi

# add disk image
if [ -n "${1}" ]; then \
    image="file=${1},discard=on,if=virtio"
    shift
fi
# add shared folder
if [ -n "${1}" ]; then \
    share="-fsdev local,id=qshare,path=${1},security_model=none -device virtio-9p-pci,fsdev=qshare,mount_tag=share"
    shift
fi

# start VM instance
exec qemu-system-x86_64 -enable-kvm -boot order=c -m 1G -drive "${image}" $share $serial "$@"
