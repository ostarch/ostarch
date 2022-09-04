#!/usr/bin/env bash
#--------------------------------------------------------------------
#   █████╗ ██████╗  ██████╗██╗  ██╗██████╗  █████╗ ██╗   ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔══██╗██║   ██║██╔════╝
#  ███████║██████╔╝██║     ███████║██║  ██║███████║██║   ██║█████╗  
#  ██╔══██║██╔══██╗██║     ██╔══██║██║  ██║██╔══██║╚██╗ ██╔╝██╔══╝  
#  ██║  ██║██║  ██║╚██████╗██║  ██║██████╔╝██║  ██║ ╚████╔╝ ███████╗
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚══════╝
#--------------------------------------------------------------------
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

source $SCRIPT_DIR/install.conf

if [ $(whoami) = "root"  ]; then
  echo "Don't run this as root!"
  exit
fi

$SCRIPT_DIR/functions/dotfiles.sh

if ! pacman -Qi yay &>/dev/null; then
  $SCRIPT_DIR/functions/install/yay.sh
fi

echo -ne "
--------------------------------------------------------------------
                       Installing AUR Packages
--------------------------------------------------------------------
"

$SCRIPT_DIR/functions/install/install-packages.sh --aur aur

mkdir -p ~/.config/autostart
cat <<EOF > ~/.config/autostart/wallpaper-post-startup.desktop
[Desktop Entry]
Exec=$SCRIPT_DIR/functions/wallpaper.sh
Icon=dialog-scripts
Name=wallpaper-post-startup
Path=
Type=Application
X-KDE-AutostartScript=true
X-KDE-autostart-phase=2
X-KDE-startup-notify=false
EOF

echo -ne "
--------------------------------------------------------------------
                  System ready for 4-post-setup.sh
--------------------------------------------------------------------
"
