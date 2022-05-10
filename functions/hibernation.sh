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
  configured="false"
  if [[ "$SWAP_TYPE" == "partition" && -n "$SWAP_PARTITION" ]]; then
    swap_uuid=$(blkid -s UUID -o value "$SWAP_PARTITION")
    if [ -n "$swap_uuid" ]; then
      sed -i -E "s/GRUB_CMDLINE_LINUX_DEFAULT=\"(.*)\"/GRUB_CMDLINE_LINUX_DEFAULT=\"\1 resume=UUID=$swap_uuid\"/" /etc/default/grub
      configured="true"
    fi
  elif [[ "$SWAP_TYPE" == "file" && -f /swapfile ]]; then
    root_uuid=$(blkid -s UUID -o value "$ROOT_PARTITION")
    swap_file_offset=$(filefrag -v /swapfile | awk '$1=="0:" {print substr($4, 1, length($4)-2)}')
    if [[ -n "$root_uuid" && -n "$swap_file_offset" ]]; then
      sed -i -E "s/GRUB_CMDLINE_LINUX_DEFAULT=\"(.*)\"/GRUB_CMDLINE_LINUX_DEFAULT=\"\1 resume=UUID=$root_uuid resume_offset=$swap_file_offset\"/" /etc/default/grub
      configured="true"
    fi
  fi

  if [ "$configured" == "true" ]; then
    if ! grep ^HOOKS /etc/mkinitcpio.conf | grep -q resume; then
      sed -i '/^HOOKS/s/filesystems/filesystems resume/' /etc/mkinitcpio.conf
    fi

    sed -i 's/HibernateDelaySec=.*/HibernateDelaySec=30min/' /etc/systemd/sleep.conf
    sed -i 's/#HibernateDelaySec=/HibernateDelaySec=/' /etc/systemd/sleep.conf

    sed -i 's/HandleLidSwitch=.*/HandleLidSwitch=suspend-then-hibernate/' /etc/systemd/logind.conf
    sed -i 's/#HandleLidSwitch=/HandleLidSwitch=/' /etc/systemd/logind.conf
  fi
fi