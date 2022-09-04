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

zsh="My dotfiles + KDE configuration"
grub="Grub Customization"
swap="Configure Swap"
hibernation="Enable Hibernation"
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
  options+=("$swap" "")
  options+=("$hibernation" "")
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
    return 0
  fi
  case ${sel} in
    "$zsh")
      "$SCRIPT_DIR/functions/dotfiles.sh"
      nextItem="$grub"
      ;;
    "$grub")
      "$SCRIPT_DIR/functions/grub.sh"
      nextItem="$swap"
      ;;
    "$swap")
      nextItem="$swap"
      setupSwapOrHibernation swap || return 3
      nextItem="$keyboard"
      ;;
    "$hibernation")
      nextItem="$hibernation"
      setupSwapOrHibernation hibernation || return 3
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
      nextItem="$base_packages"
      setInstallType || return 3
      "$SCRIPT_DIR/functions/install/install-packages.sh" pacman || return 1
      "$SCRIPT_DIR/functions/install/install-packages.sh" pacman-gaming || return 1
      if ! pacman -Qi yay &>/dev/null; then
        "$SCRIPT_DIR/functions/install/yay.sh" || return 1
      fi
      "$SCRIPT_DIR/functions/install/install-packages.sh" --aur aur || return 1
      nextItem="$desktop_environment"
      ;;
    "$desktop_environment")
      nextItem="$desktop_environment"
      menuFlow setDesktopEnvironment setInstallType || return 3
      source "$SCRIPT_DIR/install.conf" &>/dev/null
      if [ -f "$SCRIPT_DIR/packages/desktop-environments/$DESKTOP_ENV.txt" ]; then
        $SCRIPT_DIR/functions/install/install-packages.sh desktop-environments/$DESKTOP_ENV || return 1
      fi
      nextItem="$xdg"
      ;;
    "$xdg")
      "$SCRIPT_DIR/functions/xdg-portal.sh"
      nextItem="$add_user"
      ;;
    "$add_user")
      "$SCRIPT_DIR/functions/user.sh"
      nextItem="$zsh"
      ;;
  esac
  return 3
}
setupSwapOrHibernation() {
  if [ "$1" == "hibernation" ]; then
    menu selectSwapPartitionMenu swapOnly || return 1
    HIBERNATE_TYPE="hibernate"
  else
    menu selectSwapPartitionMenu || return 1
  fi
  ROOT_PARTITION=$(df --output=source / | sed -e /^Filesystem/d)
  [[ -z "$SWAP_TYPE" || "$SWAP_TYPE" == "none" || -z "$ROOT_PARTITION" ]] && return 1
  echo "SWAP_TYPE=$SWAP_TYPE" >> "$SCRIPT_DIR/install.conf"
  echo "HIBERNATE_TYPE=$HIBERNATE_TYPE" >> "$SCRIPT_DIR/install.conf"
  echo "SWAP_PARTITION=$SWAP_PARTITION" >> "$SCRIPT_DIR/install.conf"
  echo "ROOT_PARTITION=$ROOT_PARTITION" >> "$SCRIPT_DIR/install.conf"

  [ "$1" == "swap" ] && "$SCRIPT_DIR/functions/swap.sh"
  [ "$HIBERNATE_TYPE" == "hibernate" ] && "$SCRIPT_DIR/functions/hibernation.sh"
}
menu configurationMenu
