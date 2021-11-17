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

if [ -z "$DISK" ]; then
  source "${CURRENT_DIR}/select-disk.sh"
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

result=$(whiptail --title "Select Partitions" --menu "Select boot device:" 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3)
if [ ! "$?" = "0" ]; then
  source "${CURRENT_DIR}/../exit.sh"
fi
BOOT_PARTITION=${result%%\ *}

result=$(whiptail --title "Select Partitions" --menu "Select root device:" 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3)
if [ ! "$?" = "0" ]; then
  source "${CURRENT_DIR}/../exit.sh"
fi
ROOT_PARTITION=${result%%\ *}
