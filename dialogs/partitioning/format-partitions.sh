#!/bin/bash
#--------------------------------------------------------------------
#   █████╗ ██████╗  ██████╗██╗  ██╗██████╗  █████╗ ██╗   ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔══██╗██║   ██║██╔════╝
#  ███████║██████╔╝██║     ███████║██║  ██║███████║██║   ██║█████╗  
#  ██╔══██║██╔══██╗██║     ██╔══██║██║  ██║██╔══██║╚██╗ ██╔╝██╔══╝  
#  ██║  ██║██║  ██║╚██████╗██║  ██║██████╔╝██║  ██║ ╚████╔╝ ███████╗
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚══════╝
#--------------------------------------------------------------------
formatPartitionsMenu() {
  if [[ -z "$BOOT_PARTITION" || -z "$ROOT_PARTITION" ]]; then
    return 1
  fi

  options=()
	options+=("Format partitions" "")
	options+=("Mount and Install" "")
	result=$(whiptail --backtitle "${TITLE}" --title "Format and Install" --menu "" 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3)
  if [ ! "$?" = "0" ]; then
    unset BOOT_PARTITION
    unset ROOT_PARTITION
    unset SWAP_PARTITION
    return 1
  fi
  case "$result" in
    "Format partitions")
      if (whiptail --backtitle "${TITLE}" --title "Format partitions" \
          --yesno "Are you sure you want to format these partitions?\nAll data on selected partitions will be erased!" --defaultno 0 0); then
        
        setupBootPartition
        local bootExitCode="$?"
        setupRootPartition
        local rootExitCode="$?"
        if [[ -n "$SWAP_PARTITION" && "$SWAP_PARTITION" != "none" ]]; then
          setupSwapPartition
        fi
        if [[ ! "$bootExitCode" = "0" && ! "$rootExitCode" = "0" ]]; then
          return 3
        else
          configurationMenuScript
          if [ ! "$?" = "0" ]; then
            return 3
          fi
          return 2
        fi
      fi
      ;;
    "Mount and Install")
      configurationMenuScript
      if [ ! "$?" = "0" ]; then
        return 3
      fi
      return 2
      ;;
  esac
}

setupBootPartition() {
  umount -R /mnt &> /dev/null
  options=()
  options+=("fat32" "(recommended)")
  options+=("ext4" "")
  result=$(whiptail --backtitle "${TITLE}" --title "Format boot partition" --menu "Select partition format for boot ($BOOT_PARTITION):" 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3)
  if [ ! "$?" = "0" ]; then
    return 1
  fi
  case "$result" in
    "fat32")
      mkfs.vfat -F32 -n "BOOT" "${BOOT_PARTITION}"
      ;;
    "ext4")
      yes | mkfs.ext4 -L "BOOT" "${BOOT_PARTITION}"
      ;;
  esac
}

setupRootPartition() {
  umount -R /mnt &> /dev/null
  options=()
  options+=("ext4" "(recommended)")
  options+=("btrfs" "")
  options+=("xfs" "")
  result=$(whiptail --backtitle "${TITLE}" --title "Format root partition" --menu "Select partition format for root ($ROOT_PARTITION):" 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3)
  if [ ! "$?" = "0" ]; then
    return 1
  fi
  case "$result" in
    "ext4")
      yes | mkfs.ext4 -L "ROOT" "${ROOT_PARTITION}"
      ;;
    "btrfs")
      mkfs.btrfs -L "ROOT" -f "${ROOT_PARTITION}"
      ;;
    "xfs")
      mkfs.xfs -L "ROOT" -f "${ROOT_PARTITION}"
      ;;
  esac
}

setupSwapPartition() {
  umount -R /mnt &> /dev/null
  options=()
  options+=("swap" "")
  result=$(whiptail --backtitle "${TITLE}" --title "Format swap partition" --menu "Select partition format for swap ($SWAP_PARTITION):" 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3)
  if [ ! "$?" = "0" ]; then
    return 1
  fi
  case "$result" in
    "swap")
      mkswap -L "SWAP" "${SWAP_PARTITION}"
      ;;
  esac
}