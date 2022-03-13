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

if [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ -z "$1" ]; then
  echo "Usage: install-packages.sh [--help] [--aur|--pacman] <package-filename>"
  echo "  --help: show this help"
  echo "  --pacman: install packages from pacman (default)"
  echo "  --aur: install packages from AUR with yay"
  echo "  <package-filename>: the filename in the packages directory"
  echo "    for example: 'pacman', 'pacman-gaming', 'aur', 'desktop-environments/kde'"
  echo
  exit
fi

filename="$CURRENT_DIR/../../packages/${@: -1}.txt"
if [ ! -f "$filename" ]; then
  echo "Error: file '$filename' does not exist"
  exit
fi

command="sudo pacman"
if [ "$1" = "--aur" ]; then
  command="yay"
fi

source "$CURRENT_DIR/../../install.conf" &> /dev/null
packages=$(sed -e "/^#/d" -e "s/ #.*//" "$filename")
if [ "$INSTALL_TYPE" = "full" ]; then
  packages=$(echo "$packages" | sed -e '/--END OF MINIMAL INSTALL--/d')
elif [ "$INSTALL_TYPE" = "minimal" ]; then
  packages=$(echo "$packages" | sed -e '/--END OF MINIMAL INSTALL--/Q')
else
  if [ "$1" = "--aur" ]; then
    packages=$(echo "$packages" | sed -e '/--END OF MINIMAL INSTALL--/Q')
  else
    packages=$(echo "$packages" | sed -e '/--END OF MINIMAL INSTALL--/d')
  fi
fi
packages=$(echo "$packages" | sed -e 's/ //g')
if [ ! -z "$packages" ]; then
  echo "$packages" | $command -S --needed --noconfirm -
fi