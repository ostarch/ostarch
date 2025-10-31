#!/bin/bash
#--------------------------------------------------------------------
#   ██████╗ ███████╗████████╗     █████╗ ██████╗  ██████╗██╗  ██╗
#  ██╔═══██╗██╔════╝╚══██╔══╝    ██╔══██╗██╔══██╗██╔════╝██║  ██║
#  ██║   ██║███████╗   ██║       ███████║██████╔╝██║     ███████║
#  ██║   ██║╚════██║   ██║       ██╔══██║██╔══██╗██║     ██╔══██║
#  ╚██████╔╝███████║   ██║       ██║  ██║██║  ██║╚██████╗██║  ██║
#   ╚═════╝ ╚══════╝   ╚═╝       ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝
#--------------------------------------------------------------------
CONFIG_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

setInstallDotfilesMenu() {
  INSTALL_DOTFILES="no"
  if (whiptail --backtitle "${TITLE}" --title "Install Dotfiles" --yesno "This will additionally install various dotfiles including Zsh with Oh My Zsh, KDE settings and other miscellaneous configurations" 0 0); then
    INSTALL_DOTFILES="yes"
  fi
  echo "INSTALL_DOTFILES=$INSTALL_DOTFILES" >> "${CONFIG_DIR}/../../install.conf"
}