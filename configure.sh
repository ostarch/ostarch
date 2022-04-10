#!/bin/bash
#--------------------------------------------------------------------
#   █████╗ ██████╗  ██████╗██╗  ██╗██████╗  █████╗ ██╗   ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔══██╗██║   ██║██╔════╝
#  ███████║██████╔╝██║     ███████║██║  ██║███████║██║   ██║█████╗  
#  ██╔══██║██╔══██╗██║     ██╔══██║██║  ██║██╔══██║╚██╗ ██╔╝██╔══╝  
#  ██║  ██║██║  ██║╚██████╗██║  ██║██████╔╝██║  ██║ ╚████╔╝ ███████╗
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚══════╝
#--------------------------------------------------------------------
if [ $(whoami) = "root"  ]; then
  echo "Don't run this as root!"
  exit
fi
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
graphics_drivers="Install Graphics Drivers and Microcode"
base_packages="Install Base Packages"
desktop_environment="Install Desktop Environment"
xdg="Always use KDE File Picker"
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
  options+=("$graphics_drivers" "")
  options+=("$base_packages" "")
  options+=("$desktop_environment" "")
  options+=("$xdg" "")
  options+=("$kde_import" "")
  options+=("$kde_export" "")
  options+=("$add_user" "")
  sel=$(whiptail --backtitle "$TITLE" --title "Configuration Menu" --menu "" --cancel-button "Exit" 0 0 0 "${options[@]}" --default-item "$nextItem" 3>&1 1>&2 2>&3)
  if [ ! "$?" = "0" ]; then
    exit
  fi
  case ${sel} in
    "$zsh")
      "$SCRIPT_DIR/functions/dotfiles.sh"
      nextItem="$grub"
      ;;
    "$grub")
      "$SCRIPT_DIR/functions/grub.sh"
      nextItem="$keyboard"
      ;;
    "$keyboard")
      "$SCRIPT_DIR/functions/keyboard-layout.sh"
      nextItem="$locale"
      ;;
    "$locale")
      "$SCRIPT_DIR/functions/locale.sh"
      nextItem="$hostname"
      ;;
    "$hostname")
      "$SCRIPT_DIR/functions/hostname.sh"
      nextItem="$shutdown_timeout"
      ;;
    "$shutdown_timeout")
      "$SCRIPT_DIR/functions/shutdown-timeout.sh"
      nextItem="$mirrors"
      ;;
    "$mirrors")
      "$SCRIPT_DIR/functions/mirrors.sh"
      nextItem="$pacman"
      ;;
    "$pacman")
      "$SCRIPT_DIR/functions/pacman.sh"
      nextItem="$graphics_drivers"
      ;;
    "$graphics_drivers")
      sudo "$SCRIPT_DIR/functions/install/microcode.sh"
      sudo "$SCRIPT_DIR/functions/install/graphics-drivers.sh"
      nextItem="$base_packages"
      ;;
    "$base_packages")
      setInstallType || return 0
      "$SCRIPT_DIR/functions/install/install-packages.sh" pacman || return 1
      "$SCRIPT_DIR/functions/install/install-packages.sh" pacman-gaming || return 1
      if ! pacman -Qi yay &>/dev/null; then
        "$SCRIPT_DIR/functions/install/yay.sh" || return 1
      fi
      "$SCRIPT_DIR/functions/install/install-packages.sh" --aur aur || return 1
      nextItem="$desktop_environment"
      ;;
    "$desktop_environment")
      menuFlow setDesktopEnvironment setInstallType || return 0
      source "$SCRIPT_DIR/install.conf" &>/dev/null
      if [ -f "$SCRIPT_DIR/packages/desktop-environments/$DESKTOP_ENV.txt" ]; then
        $SCRIPT_DIR/functions/install/install-packages.sh desktop-environments/$DESKTOP_ENV || return 1
      fi
      nextItem="$xdg"
      ;;
    "$xdg")
      "$SCRIPT_DIR/functions/xdg-portal.sh"
      nextItem="$kde_import"
      ;;
    "$kde_import")
      "$SCRIPT_DIR/functions/kde-import.sh"
      nextItem="$kde_export"
      ;;
    "$kde_export")
      "$SCRIPT_DIR/functions/kde-export.sh"
      nextItem="$add_user"
      ;;
    "$add_user")
      "$SCRIPT_DIR/functions/user.sh"
      nextItem="$zsh"
      ;;
  esac
}
menu configurationMenu