#!/bin/bash
#--------------------------------------------------------------------
#   █████╗ ██████╗  ██████╗██╗  ██╗██████╗  █████╗ ██╗   ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔══██╗██║   ██║██╔════╝
#  ███████║██████╔╝██║     ███████║██║  ██║███████║██║   ██║█████╗  
#  ██╔══██║██╔══██╗██║     ██╔══██║██║  ██║██╔══██║╚██╗ ██╔╝██╔══╝  
#  ██║  ██║██║  ██║╚██████╗██║  ██║██████╔╝██║  ██║ ╚████╔╝ ███████╗
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚══════╝
#--------------------------------------------------------------------
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source "$SCRIPT_DIR/dialogs/menu.sh"

index=0
configurationMenu() {
  rm "$SCRIPT_DIR/install.conf" 2> /dev/null
  options=()
  options+=("Grub Customization" "") 
  options+=("Set Keyboard Layout" "")
  options+=("Set Locale and Timezone" "")
  options+=("Set Hostname" "")
  options+=("Set Systemd Shutdown Timeout" "")
  options+=("Update Mirrors" "")
  options+=("Pacman Customization" "")
  options+=("Import KDE Configuration" "")
  options+=("Export KDE Configuration" "")
  options+=("Add User" "")
  sel=$(whiptail --backtitle "$TITLE" --title "Configuration Menu" --menu "" --cancel-button "Exit" 0 0 0 "${options[@]}" --default-item "${options[$index]}" 3>&1 1>&2 2>&3)
  if [ ! "$?" = "0" ]; then
    exit
  fi
  case ${sel} in
    "Grub Customization")
      "$SCRIPT_DIR/functions/grub.sh"
      index=2
      ;;
    "Set Keyboard Layout")
      "$SCRIPT_DIR/functions/keyboard-layout.sh"
      index=4
      ;;
    "Set Locale and Timezone")
      "$SCRIPT_DIR/functions/locale.sh"
      index=6
      ;;
    "Set Hostname")
      "$SCRIPT_DIR/functions/sethostname.sh"
      index=8
      ;;
    "Set Systemd Shutdown Timeout")
      "$SCRIPT_DIR/functions/shutdown-timeout.sh"
      index=10
      ;;
    "Update Mirrors")
      "$SCRIPT_DIR/functions/mirrors.sh"
      index=12
      ;;
    "Pacman Customization")
      "$SCRIPT_DIR/functions/pacman.sh"
      index=14
      ;;
    "Import KDE Configuration")
      "$SCRIPT_DIR/functions/kde-import.sh"
      index=16
      ;;
    "Export KDE Configuration")
      "$SCRIPT_DIR/functions/kde-export.sh"
      index=18
      ;;
    "Add User")
      "$SCRIPT_DIR/functions/adduser.sh"
      index=0
      ;;
  esac
}
menu configurationMenu