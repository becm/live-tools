#!/bin/sh
# live-tools/aliases.sh: functions for live system base VM

# create live system files in 9p share
mklive () {
# requires:
#   - 9p-share of host system folder (see live-tools/qemu.sh)
#   - live-tools/mklive.sh in shared folder
# live-tools folder can be used as share
  local dest="${1}"
  [ -n "${dest}" ] || dest='/mnt'
  
  local root=`mktemp -d -p /run live-tools.XXXXX`
  [ -n "${root}" ] || return 1
  
  mkdir -p "${root}" && \
  mount -t 9p share "${dest}" && \
  mount /dev/vda1 "${root}" && \
  "${dest}"/mklive.sh create "${root}" "${dest}"
  
  umount "${root}" "${dest}"
  rmdir "${root}"
}

# script command selection when called
[ -n "$-" ] || {
    case "${1}" in
        mklive) shift; mklive "${@}";;
        '') printf '%s: %s\n' "${0}" 'need operation argument' 1>&2; return 1;;
        *)  printf '%s: %s\n' "${0}" 'bad operation argument'  1>&2; return 1;;
    esac
}
