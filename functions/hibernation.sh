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
swapFile="/swapfile"
[ "$(lsblk -plnf -o FSTYPE "$ROOT_PARTITION")" == "btrfs" ] && swapFile="/swap/swapfile"
if [ "$HIBERNATE_TYPE" == "hibernate" ]; then
  configured="false"
  if [[ "$SWAP_TYPE" == "partition" && -n "$SWAP_PARTITION" ]]; then
    swap_uuid=$(blkid -s UUID -o value "$SWAP_PARTITION")
    if [ -n "$swap_uuid" ]; then
      sed -i -E 's/resume=UUID=.* //' /etc/default/grub
      sed -i -E 's/ resume=UUID=.*"/"/' /etc/default/grub
      sed -i -E "s/GRUB_CMDLINE_LINUX_DEFAULT=\"(.*)\"/GRUB_CMDLINE_LINUX_DEFAULT=\"\1 resume=UUID=$swap_uuid\"/" /etc/default/grub
      configured="true"
    fi
  elif [[ "$SWAP_TYPE" == "file" && -f "$swapFile" ]]; then
    root_uuid=$(blkid -s UUID -o value "$ROOT_PARTITION")
    swap_file_offset=$(filefrag -v "$swapFile" | awk '$1=="0:" {print substr($4, 1, length($4)-2)}')
    if [[ -n "$root_uuid" && -n "$swap_file_offset" ]]; then
      sed -i -E 's/resume=UUID=.* //' /etc/default/grub
      sed -i -E 's/ resume=UUID=.*"/"/' /etc/default/grub
      sed -i -E 's/resume_offset=.* //' /etc/default/grub
      sed -i -E 's/ resume_offset=.*"/"/' /etc/default/grub
      sed -i -E "s/GRUB_CMDLINE_LINUX_DEFAULT=\"(.*)\"/GRUB_CMDLINE_LINUX_DEFAULT=\"\1 resume=UUID=$root_uuid resume_offset=$swap_file_offset\"/" /etc/default/grub
      configured="true"
    fi
  fi

  if [ "$configured" == "true" ]; then
    echo "--------------------------------------------------------------------"
    echo "                        Enabling Hibernation                        "
    echo "--------------------------------------------------------------------"
    if ! grep ^HOOKS /etc/mkinitcpio.conf | grep -q resume; then
      sed -i '/^HOOKS/s/filesystems/filesystems resume/' /etc/mkinitcpio.conf
      mkinitcpio -P
    fi
    if [ -f /boot/grub/grub.cfg ]; then
      grub-mkconfig -o /boot/grub/grub.cfg
    fi

    sed -i 's/HibernateDelaySec=.*/HibernateDelaySec=30min/' /etc/systemd/sleep.conf
    sed -i 's/#HibernateDelaySec=/HibernateDelaySec=/' /etc/systemd/sleep.conf

    sed -i 's/HandleLidSwitch=.*/HandleLidSwitch=suspend-then-hibernate/' /etc/systemd/logind.conf
    sed -i 's/#HandleLidSwitch=/HandleLidSwitch=/' /etc/systemd/logind.conf

    sed -i 's/AllowHibernation=.*/AllowHibernation=yes/' /etc/systemd/sleep.conf
    sed -i 's/#AllowHibernation=/AllowHibernation=/' /etc/systemd/sleep.conf

    sed -i 's/AllowSuspendThenHibernate=.*/AllowSuspendThenHibernate=yes/' /etc/systemd/sleep.conf
    sed -i 's/#AllowSuspendThenHibernate=/AllowSuspendThenHibernate=/' /etc/systemd/sleep.conf

  fi
else
  sed -i 's/AllowHibernation=.*/AllowHibernation=no/' /etc/systemd/sleep.conf
  sed -i 's/#AllowHibernation=/AllowHibernation=/' /etc/systemd/sleep.conf

  sed -i 's/AllowSuspendThenHibernate=.*/AllowSuspendThenHibernate=no/' /etc/systemd/sleep.conf
  sed -i 's/#AllowSuspendThenHibernate=/AllowSuspendThenHibernate=/' /etc/systemd/sleep.conf
fi