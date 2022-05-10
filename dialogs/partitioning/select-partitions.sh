#!/bin/bash
#--------------------------------------------------------------------
#   █████╗ ██████╗  ██████╗██╗  ██╗██████╗  █████╗ ██╗   ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔══██╗██║   ██║██╔════╝
#  ███████║██████╔╝██║     ███████║██║  ██║███████║██║   ██║█████╗  
#  ██╔══██║██╔══██╗██║     ██╔══██║██║  ██║██╔══██║╚██╗ ██╔╝██╔══╝  
#  ██║  ██║██║  ██║╚██████╗██║  ██║██████╔╝██║  ██║ ╚████╔╝ ███████╗
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚══════╝
#--------------------------------------------------------------------
selectPartitionMenu() {
  if [[ -n "${1}" ]]; then
    DISK="${1}"
  else
    selectDiskMenu
    if [ ! "$?" = "0" ]; then
      return 1
    fi
  fi
  items=$(lsblk -pln -o NAME,SIZE -e 7,11 "$DISK")
  options=()
  IFS_ORIG=$IFS
  IFS=$'\n'
  for item in ${items}
  do
    if [[ "${item%%\ *}" == "$DISK" ]]; then
      continue
    fi
    options+=("$item" "")
  done
  IFS=$IFS_ORIG

  result=$(whiptail --backtitle "$TITLE" --title "Select Partitions" --menu "Select boot device:" 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3)
  if [ ! "$?" = "0" ]; then
    return 1
  fi
  BOOT_PARTITION=${result%%\ *}

  result=$(whiptail --backtitle "$TITLE" --title "Select Partitions" --menu "Select root device:" 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3)
  if [ ! "$?" = "0" ]; then
    return 1
  fi
  ROOT_PARTITION=${result%%\ *}

  options=("none" "" "${options[@]}")
  result=$(whiptail --backtitle "$TITLE" --title "Select Partitions" --menu "Select swap device:" 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3)
  if [ ! "$?" = "0" ]; then
    return 1
  fi
  SWAP_PARTITION=${result%%\ *}

  SWAP_OPTION="$SWAP_PARTITION"

  if [[ "$SWAP_PARTITION" == "none" ]]; then
    menu selectSwapOption file
    if [ "$?" == "1" ]; then
      return 1
    fi
    if [ "$SWAP_TYPE" == "file" ]; then
      if [ "$HIBERNATE_TYPE" == "hibernate" ]; then
        SWAP_OPTION="Swap File (with Hibernation)"
      else
        SWAP_OPTION="Swap File (without Hibernation)"
      fi
    fi
  fi


  msg="Selected devices:\n\n"
	msg="${msg}boot: ${BOOT_PARTITION}\n"
	msg="${msg}root: ${ROOT_PARTITION}\n"
	msg="${msg}swap: ${SWAP_OPTION}\n\n"
  msg="${msg}Continue?"
  if (whiptail --backtitle "$TITLE" --title "Install" --yesno "$msg" --defaultno 0 0); then
    menu formatPartitionsMenu
    return "$?"
  else
    unset BOOT_PARTITION
    unset ROOT_PARTITION
    unset SWAP_PARTITION
    return 1
  fi
}
