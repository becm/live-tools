#!/bin/sh
# live-tools/aliases.sh: functions for live system base VM

# create live system files in 9p share
mklive () {
# requires:
#   - 9p-share of host system folder (see live-tools/qemu.sh)
#   - live-tools/mklive.sh in shared folder
# live-tools folder can be used as target directory
  local dest="${1}"
  [ -n "${dest}" ] || dest='/mnt'
  
  # import shared folder
  mount -t 9p -o trans=virtio share "${dest}" || return 1
  
  # check target directory requirements
  [ -x "${dest}"/mklive.sh ] || {
    printf '%s: %s\n' "${0}" 'live creation script not found target directory'
    umount "${dest}"
    return 2
  }
  # clean system mount
  local root=`mktemp -d -p /run live-tools.XXXXX`
  [ -n "${root}" ] || return 3
    
  # create image from clean location
  mkdir -p "${root}" && \
  mount /dev/vda1 "${root}" && \
  "${dest}"/mklive.sh create "${root}" "${dest}"
  
  # mount and tempdir cleanup
  umount "${root}" "${dest}"
  rmdir "${root}"
}
