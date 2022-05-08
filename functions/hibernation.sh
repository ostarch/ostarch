#!/usr/bin/env bash
#--------------------------------------------------------------------
#   █████╗ ██████╗  ██████╗██╗  ██╗██████╗  █████╗ ██╗   ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔══██╗██║   ██║██╔════╝
#  ███████║██████╔╝██║     ███████║██║  ██║███████║██║   ██║█████╗  
#  ██╔══██║██╔══██╗██║     ██╔══██║██║  ██║██╔══██║╚██╗ ██╔╝██╔══╝  
#  ██║  ██║██║  ██║╚██████╗██║  ██║██████╔╝██║  ██║ ╚████╔╝ ███████╗
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚══════╝
#--------------------------------------------------------------------
[ "$(id -u)" = "0" ] || exec sudo "$0" "$@"
CURRENT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"


source "$CURRENT_DIR/../install.conf" &> /dev/null
if [ "$HIBERNATE_TYPE" == "hibernate" ]; then
  echo "--------------------------------------------------------------------"
  echo "                        Enabling Hibernation                        "
  echo "--------------------------------------------------------------------"
  if [[ "$SWAP_TYPE" == "partition" && -n "$SWAP_PARTITION" ]]; then
    swap_uuid=$(blkid -s UUID -o value "$SWAP_PARTITION")
    if [ -n "$swap_uuid" ]; then
      echo "options resume=UUID=$swap_uuid" > /etc/modprobe.d/hibernate.conf
    fi
  elif [[ "$SWAP_TYPE" == "file" && -f /swapfile ]]; then
    root_uuid=$(blkid -s UUID -o value "$ROOT_PARTITION")
    swap_file_offset=$(filefrag -v /swapfile | awk '$1=="0:" {print substr($4, 1, length($4)-2)}')
    if [[ -n "$root_uuid" && -n "$swap_file_offset" ]]; then
      echo "options resume=UUID=$root_uuid resume_offset=$swap_file_offset" > /etc/modprobe.d/hibernate.conf
    fi
  fi

  if [ -f /etc/modprobe.d/hibernate.conf ]; then
    if ! grep ^HOOKS /etc/mkinitcpio.conf | grep -q resume; then
      sed -i '/^HOOKS/s/filesystems/filesystems resume/' /etc/mkinitcpio.conf
    fi
    mkinitcpio -P
  fi
fi