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
BASENAME="$( basename $SCRIPT_DIR)"

echo -ne "
-------------------------------------------------------------------------
                              Network Setup
-------------------------------------------------------------------------
"
pacman -S networkmanager dhclient --noconfirm --needed
systemctl enable --now NetworkManager

$SCRIPT_DIR/functions/mirrors.sh

$SCRIPT_DIR/functions/makeflags.sh

$SCRIPT_DIR/functions/locale.sh

# Add sudo no password rights
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

$SCRIPT_DIR/functions/pacman.sh


$SCRIPT_DIR/functions/install/microcode.sh
$SCRIPT_DIR/functions/install/graphics-drivers.sh

echo -ne "
-------------------------------------------------------------------------
                    Installing Base System  
-------------------------------------------------------------------------
"
$SCRIPT_DIR/functions/install/install-packages.sh pacman

echo -ne "
-------------------------------------------------------------------------
                    Installing Gaming Drivers
-------------------------------------------------------------------------
"
$SCRIPT_DIR/functions/install/install-packages.sh pacman-gaming

source "$SCRIPT_DIR/functions/adduser.sh"

$SCRIPT_DIR/functions/sethostname.sh
$SCRIPT_DIR/functions/keyboard-layout.sh
$SCRIPT_DIR/functions/shutdown-timeout.sh

cp -R "/root/$BASENAME" "/home/$USERNAME/$BASENAME"
chown -R $USERNAME: "/home/$USERNAME/$BASENAME"
echo -ne "
-------------------------------------------------------------------------
                    System ready for 2-user.sh
-------------------------------------------------------------------------
"