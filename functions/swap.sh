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
root="/"
if [ -n "$1" ]; then
  root="$1/"
fi
swapFile="${root}swapfile"
fstabFile="${root}etc/fstab"
if [ "$(lsblk -plnf -o FSTYPE "$ROOT_PARTITION")" == "btrfs" ]; then
  if [ ! -d "${root}swap" ]; then
    mkdir "${root}swap"
    btrfs subvolume create "${root}@swap"
    mount -o subvol=@swap $ROOT_PARTITION /mnt/swap
  fi
  swapFile="${root}swap/swapfile"
  chattr +C "${root}swap"
fi
if [[ "$SWAP_TYPE" == "file" ]]; then
  swapSize=$(getSwapSpace)
  if [[ "$swapSize" -gt 0 ]]; then
    if [ ! -f "$swapFile" ]; then
      echo
      echo "--------------------------------------------------------------------"
      echo "                         Creating Swap File                         "
      echo "--------------------------------------------------------------------"
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