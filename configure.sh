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

zsh="Zsh Configuration + dotfiles"
grub="Grub Customization"
keyboard="Set Keyboard Layout"
locale="Set Locale and Timezone"
hostname="Set Hostname"
shutdown_timeout="Set Systemd Shutdown Timeout"
mirrors="Update System Mirrors"
pacman="Pacman Customization"
kde_import="Import KDE Configuration"
kde_export="Export KDE Configuration"
add_user="Add User"

nextItem="$zsh"
configurationMenu() {
  rm "$SCRIPT_DIR/install.conf" 2> /dev/null
  options=()
  options+=("$zsh" "") 
  options+=("$grub" "") 
  options+=("$keyboard" "")
  options+=("$locale" "")
  options+=("$hostname" "")
  options+=("$shutdown_timeout" "")
  options+=("$mirrors" "")
  options+=("$pacman" "")
  options+=("$kde_import" "")
  options+=("$kde_export" "")
  options+=("$add_user" "")
  sel=$(whiptail --backtitle "$TITLE" --title "Configuration Menu" --menu "" --cancel-button "Exit" 0 0 0 "${options[@]}" --default-item "$nextItem" 3>&1 1>&2 2>&3)
  if [ ! "$?" = "0" ]; then
    exit
  fi
  case ${sel} in
    "Zsh Configuration + dotfiles")
      "$SCRIPT_DIR/functions/dotfiles.sh"
      nextItem="$grub"
      ;;
    "Grub Customization")
      "$SCRIPT_DIR/functions/grub.sh"
      nextItem="$keyboard"
      ;;
    "Set Keyboard Layout")
      "$SCRIPT_DIR/functions/keyboard-layout.sh"
      nextItem="$locale"
      ;;
    "Set Locale and Timezone")
      "$SCRIPT_DIR/functions/locale.sh"
      nextItem="$hostname"
      ;;
    "Set Hostname")
      "$SCRIPT_DIR/functions/hostname.sh"
      nextItem="$shutdown_timeout"
      ;;
    "Set Systemd Shutdown Timeout")
      "$SCRIPT_DIR/functions/shutdown-timeout.sh"
      nextItem="$mirrors"
      ;;
    "Update Mirrors")
      "$SCRIPT_DIR/functions/mirrors.sh"
      nextItem="$pacman"
      ;;
    "Pacman Customization")
      "$SCRIPT_DIR/functions/pacman.sh"
      nextItem="$kde_import"
      ;;
    "Import KDE Configuration")
      "$SCRIPT_DIR/functions/kde-import.sh"
      nextItem="$kde_export"
      ;;
    "Export KDE Configuration")
      "$SCRIPT_DIR/functions/kde-export.sh"
      nextItem="$add_user"
      ;;
    "Add User")
      "$SCRIPT_DIR/functions/adduser.sh"
      nextItem="$zsh"
      ;;
  esac
}
menu configurationMenu