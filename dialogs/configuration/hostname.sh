#!/bin/bash
#--------------------------------------------------------------------
#   █████╗ ██████╗  ██████╗██╗  ██╗██████╗  █████╗ ██╗   ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔══██╗██║   ██║██╔════╝
#  ███████║██████╔╝██║     ███████║██║  ██║███████║██║   ██║█████╗  
#  ██╔══██║██╔══██╗██║     ██╔══██║██║  ██║██╔══██║╚██╗ ██╔╝██╔══╝  
#  ██║  ██║██║  ██║╚██████╗██║  ██║██████╔╝██║  ██║ ╚████╔╝ ███████╗
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚══════╝
#--------------------------------------------------------------------
CONFIG_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

setHostnameMenu() {
  defaultHostname="$(cat /etc/hostname)"
  if [ "$defaultHostname" = "archiso" ]; then
    defaultHostname="archlinux"
  fi
  hostname=$(whiptail --backtitle "${TITLE}" --title "Set Computer Name" --cancel-button "Back" --inputbox "Enter your hostname" 8 40 "$defaultHostname" 3>&1 1>&2 2>&3)
  if [ ! "$?" = "0" ]; then
    return 1
  fi
  if [[ ! "$hostname" =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]{1,62}$ || "${hostname: -1}" == "-" ]]; then
    whiptail --backtitle "${TITLE}" --title "Set Computer Name" --msgbox "Invalid Hostname\nOnly letters, numbers, underscore and hyphen are allowed, minimal of two characters" 8 40
    setHostnameMenu
    return "$?"
  fi
  if [ "$hostname" = "localhost" ]; then
    whiptail --backtitle "${TITLE}" --title "Set Computer Name" --msgbox "localhost is not allowed as hostname" 8 40
    setHostnameMenu
    return "$?"
  fi
  echo "HOSTNAME=$hostname" >> "${CONFIG_DIR}/../../install.conf"
}