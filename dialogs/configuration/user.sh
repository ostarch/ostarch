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

addUserMenu() {
  user=$(whiptail --backtitle "${TITLE}" --title "Add User" --cancel-button "Back" --inputbox "Enter the username" 8 40 3>&1 1>&2 2>&3)
  if [ ! "$?" = "0" ]; then
    return 1
  fi
  if [[ ! "$user" =~ ^[a-z_][a-z0-9_-]*[$]?$ ]]; then
    whiptail --backtitle "${TITLE}" --title "Add User" --msgbox "Only lowercase letters, numbers, underscore and hyphen are allowed" 8 40
    addUserMenu
    return "$?"
  fi
  if [ "$user" = "root" ]; then
    whiptail --backtitle "${TITLE}" --title "Add User" --msgbox "root is not allowed as username" 8 40
    addUserMenu
    return "$?"
  fi
  echo "USERNAME=$user" >> "${CONFIG_DIR}/../../install.conf"
}

setUserPasswordMenu() {
  password=$(whiptail --backtitle "${TITLE}" --title "Set User Password" --cancel-button "Back" --passwordbox "Enter your password" 8 40 3>&1 1>&2 2>&3)
  if [ ! "$?" = "0" ]; then
    return 1
  fi
  passwordRepeat=$(whiptail --backtitle "${TITLE}" --title "Set User Password" --cancel-button "Back" --passwordbox "Repeat your password" 8 40 3>&1 1>&2 2>&3)
  if [ ! "$?" = "0" ]; then
    return 1
  fi
  if [ "$password" != "$passwordRepeat" ]; then
    whiptail --backtitle "${TITLE}" --title "Set User Password" --msgbox "Passwords do not match" 8 40
    setUserPasswordMenu
    return "$?"
  fi
  if [ "$password" = "" ]; then
    whiptail --backtitle "${TITLE}" --title "Set User Password" --msgbox "Password cannot be empty" 8 40
    setUserPasswordMenu
    return "$?"
  fi
  encrpytedPassword=$(echo "$password" | openssl passwd -6 -stdin)
  echo "PASSWORD=${encrpytedPassword//$/\\$}" >> "${CONFIG_DIR}/../../install.conf"
}