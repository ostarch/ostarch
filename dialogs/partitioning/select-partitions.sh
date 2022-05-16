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

  BOOT_PARTITION="$(selectSpecificPartitionMenu boot)"
  if [ ! "$?" = "0" ]; then
    return 1
  fi

  ROOT_PARTITION="$(selectSpecificPartitionMenu root)"
  if [ ! "$?" = "0" ]; then
    return 1
  fi

  selectSwapPartitionMenu
  if [ ! "$?" = "0" ]; then
    return 1
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
    unsetAllVariables
    return 1
  fi
}

selectSpecificPartitionMenu() {
  items=$(lsblk -pln -o NAME,SIZE -e 7,11 "$DISK")
  options=()
  [ "$1" == "swap" ] && options+=("none" "")
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

  result=$(whiptail --backtitle "$TITLE" --title "Select Partitions" --menu "Select $1 device:" 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3)
  if [ ! "$?" = "0" ]; then
    unsetAllVariables
    return 1
  fi
  echo "${result%%\ *}"
}

selectSwapPartitionMenu() {
  SWAP_PARTITION="$(selectSpecificPartitionMenu swap)"
  if [ ! "$?" = "0" ]; then
    return 1
  fi

  SWAP_OPTION="$SWAP_PARTITION"

  if [[ "$SWAP_PARTITION" == "none" ]]; then
    menu selectSwapOption file
    if [ "$?" == "1" ]; then
      unsetAllVariables
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
}

unsetAllVariables() {
  unset BOOT_PARTITION
  unset ROOT_PARTITION
  unset SWAP_PARTITION
}