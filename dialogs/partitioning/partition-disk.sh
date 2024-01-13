#!/bin/bash
#--------------------------------------------------------------------
#   █████╗ ██████╗  ██████╗██╗  ██╗██████╗  █████╗ ██╗   ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔══██╗██║   ██║██╔════╝
#  ███████║██████╔╝██║     ███████║██║  ██║███████║██║   ██║█████╗  
#  ██╔══██║██╔══██╗██║     ██╔══██║██║  ██║██╔══██║╚██╗ ██╔╝██╔══╝  
#  ██║  ██║██║  ██║╚██████╗██║  ██║██████╔╝██║  ██║ ╚████╔╝ ███████╗
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚══════╝
#--------------------------------------------------------------------
displayWarning() {
  whiptail --backtitle "$TITLE" --title "$1" --yesno "Selected device: "$2"\n\nALL DATA WILL BE ERASED!\n\nContinue?" --defaultno 0 0 3>&1 1>&2 2>&3
  return "$?"
}

partitionDiskMenu() {
  options=()
  if [[ ! -d "/sys/firmware/efi" ]]; then
    options+=("Auto Partitions (gpt)" "")
  else
    options+=("Auto Partitions (gpt,efi)" "")
  fi
  options+=("Edit Partitions manually (cfdisk)" "")
  options+=("Edit Partitions manually (cgdisk)" "")

  partitionOption=$(whiptail --backtitle "$TITLE" --title "Disk Partitions" --cancel-button "Back" --menu "" 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3)
  if [ ! "$?" = "0" ]; then
    return 1
  fi
  selectDiskMenu
  if [ ! "$?" = "0" ]; then
    return 3
  fi
  case ${partitionOption} in
    "Auto Partitions (gpt)")
      menuFlow selectSwapOption selectHibernateOption
      if [ "$?" == "1" ]; then
        return 3
      fi
      if (displayWarning "Auto Partitions (gpt)" "$DISK"); then
        partitionDisks
      fi
    ;;
    "Auto Partitions (gpt,efi)")
      menuFlow selectSwapOption selectHibernateOption
      if [ "$?" == "1" ]; then
        return 3
      fi
      if (displayWarning "Auto Partitions (gpt,efi)" "$DISK"); then
        partitionDisks efi
      fi
    ;;
    "Edit Partitions manually (cfdisk)")
      cfdisk ${DISK}
      menu selectPartitionMenu "$DISK"
      return "$?"
    ;;
    "Edit Partitions manually (cgdisk)")
      cgdisk ${DISK}
      menu selectPartitionMenu "$DISK"
      return "$?"
    ;;
  esac

  if [[ ! -z "$BOOT_PARTITION_NUM" ]] && [[ ! -z "$ROOT_PARTITION_NUM" ]]; then
    if [[ ${DISK} =~ "nvme" ]]; then
      BOOT_PARTITION="${DISK}p${BOOT_PARTITION_NUM}"
      ROOT_PARTITION="${DISK}p${ROOT_PARTITION_NUM}"
      [[ -n "$SWAP_PARTITION_NUM" ]] && SWAP_PARTITION="${DISK}p${SWAP_PARTITION_NUM}"
    else
      BOOT_PARTITION="${DISK}${BOOT_PARTITION_NUM}"
      ROOT_PARTITION="${DISK}${ROOT_PARTITION_NUM}"
      [[ -n "$SWAP_PARTITION_NUM" ]] && SWAP_PARTITION="${DISK}${SWAP_PARTITION_NUM}"
    fi
    menu formatPartitionsMenu
    return "$?"
  fi
}

# $1 either efi or bios
# It will automatically create a swap partition if user chose swap partition
partitionDisks() {
  sgdisk -Z ${DISK} # zap all on disk
  sgdisk -a 2048 -o ${DISK} # new gpt disk 2048 alignment

  BOOT_PARTITION_NUM=1
  ROOT_PARTITION_NUM=2
  unset SWAP_PARTITION_NUM

  if [[ "$1" != "efi" ]]; then
    sgdisk -n 1::+1M --typecode=1:ef02 --change-name=1:'BIOSBOOT' ${DISK} # partition 1 (BIOS Boot Partition)
    BOOT_PARTITION_NUM=2
    ROOT_PARTITION_NUM=3
  fi

  sgdisk -n ${BOOT_PARTITION_NUM}::+512M --typecode=${BOOT_PARTITION_NUM}:ef00 --change-name=${BOOT_PARTITION_NUM}:'BOOT' ${DISK} # partition 1 (Boot Partition)
  if [[ -n "$SWAP_TYPE" && "$SWAP_TYPE" == "partition" ]]; then
    swapSize=$(getSwapSpace)
    if [ $swapSize -gt 0 ]; then
      sgdisk -n ${ROOT_PARTITION_NUM}::+${swapSize}M --typecode=${ROOT_PARTITION_NUM}:8200 --change-name=${ROOT_PARTITION_NUM}:'SWAP' ${DISK} # partition 2 (Swap)
      SWAP_PARTITION_NUM=${ROOT_PARTITION_NUM}
      ROOT_PARTITION_NUM=$((ROOT_PARTITION_NUM + 1))
    fi
  fi
  sgdisk -n ${ROOT_PARTITION_NUM}::-0 --typecode=${ROOT_PARTITION_NUM}:8300 --change-name=${ROOT_PARTITION_NUM}:'ROOT' ${DISK} # partition 2 (Root), default start, remaining
}