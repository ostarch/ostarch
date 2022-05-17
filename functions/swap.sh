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
source "$CURRENT_DIR/../dialogs/menu.sh" &> /dev/null
swapFile="/swapfile"
fstabFile="/etc/fstab"
if [ -n "$1" ]; then
  swapFile="$1$swapFile"
  fstabFile="$1$fstabFile"
fi
if [[ "$SWAP_TYPE" == "file" ]]; then
  swapSize=$(getSwapSpace)
  if [[ "$swapSize" -gt 0 ]]; then
    if [ ! -f "$swapFile" ]; then
      echo
      echo "--------------------------------------------------------------------"
      echo "                         Creating Swap File                         "
      echo "--------------------------------------------------------------------"
      if [ "$(lsblk -plnf -o FSTYPE "$ROOT_PARTITION")" == "btrfs" ]; then
        truncate -s 0 "$swapFile"
        chattr +C "$swapFile"
        btrfs property set "$swapFile" compression none
      fi
      dd if=/dev/zero of="$swapFile" bs=1M count="$swapSize" status=progress
      chmod 600 "$swapFile"
      mkswap "$swapFile"
    fi
  fi
  swapoff -a &>/dev/null
  swapon "$swapFile"
  ! grep -qE "^$swapFile" "$fstabFile" && echo -e "$swapFile\t\tnone\t\tswap\t\tdefaults\t0 0" >> "$fstabFile"
elif [[ -n "$SWAP_PARTITION" && "$SWAP_PARTITION" != "none" ]]; then
  swapoff -a &>/dev/null
  swapon "$SWAP_PARTITION"
  swap_uuid=$(blkid -s UUID -o value "$SWAP_PARTITION")
  if [[ -n "$swap_uuid" ]] && ! grep -qE "^UUID=$swap_uuid" "$fstabFile"; then
    echo -e "UUID=$swap_uuid\t\tnone\t\tswap\t\tdefaults\t0 0" >> "$fstabFile"
  fi
fi