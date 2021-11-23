#!/bin/bash
#--------------------------------------------------------------------
#   █████╗ ██████╗  ██████╗██╗  ██╗██████╗  █████╗ ██╗   ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔══██╗██║   ██║██╔════╝
#  ███████║██████╔╝██║     ███████║██║  ██║███████║██║   ██║█████╗  
#  ██╔══██║██╔══██╗██║     ██╔══██║██║  ██║██╔══██║╚██╗ ██╔╝██╔══╝  
#  ██║  ██║██║  ██║╚██████╗██║  ██║██████╔╝██║  ██║ ╚████╔╝ ███████╗
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚══════╝
#--------------------------------------------------------------------
CURRENT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

selectPartitionMenu() {
  if [[ -n "${1}" ]]; then
    DISK="${1}"
  else
    source "${CURRENT_DIR}/select-disk.sh"
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


  msg="Selected devices:\n\n"
	msg=${msg}"boot: "${BOOT_PARTITION}"\n"
	msg=${msg}"root: "${ROOT_PARTITION}"\n\n"
  msg=${msg}"Continue?"
  if (whiptail --backtitle "$TITLE" --title "Install" --yesno "$msg" --defaultno 0 0); then
    menu formatPartitionsMenu
    return "$?"
  else
    return 1
  fi
}
