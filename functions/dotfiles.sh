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

if [ $(whoami) = "root"  ]; then
  echo "Don't run this as root!"
  exit
fi

source "${CURRENT_DIR}/../install.conf" &>/dev/null

if [ -z "$INSTALL_DOTFILES" ]; then
  source "${CURRENT_DIR}/../dialogs/menu.sh"
  menuFlow setInstallDotfilesMenu
  if [ ! "$?" = "0" ]; then
    exit 1
  else
    CURRENT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    source "${CURRENT_DIR}/../install.conf"
  fi
fi

if [ "$INSTALL_DOTFILES" == "yes" ]; then
  git clone "https://github.com/d4ve10/dotfiles" ~/.dotfiles 2> /dev/null
  if [ ! "$?" = "0" ]; then
    echo "Updating dotfiles..."
    cd ~/.dotfiles && git pull
  fi
  ~/.dotfiles/install.sh minimal
  ~/.dotfiles/functions/kde.sh
else
  echo -ne "
--------------------------------------------------------------------
                   Skipping Dotfiles Installation
--------------------------------------------------------------------
"
fi