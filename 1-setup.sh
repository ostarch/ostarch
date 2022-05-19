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

$SCRIPT_DIR/functions/pacman.sh
$SCRIPT_DIR/functions/mirrors.sh
echo -ne "
--------------------------------------------------------------------
                            Network Setup
--------------------------------------------------------------------
"
pacman -S --noconfirm --needed networkmanager dhclient
systemctl enable NetworkManager

$SCRIPT_DIR/functions/makeflags.sh

$SCRIPT_DIR/functions/locale.sh

# Add sudo no password rights
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers

$SCRIPT_DIR/functions/user.sh
$SCRIPT_DIR/functions/hostname.sh
$SCRIPT_DIR/functions/keyboard-layout.sh
$SCRIPT_DIR/functions/shutdown-timeout.sh
$SCRIPT_DIR/functions/hibernation.sh
$SCRIPT_DIR/functions/xdg-portal.sh
! grep -q "PLASMA_USE_QT_SCALING=1" /etc/environment && echo "PLASMA_USE_QT_SCALING=1" >> /etc/environment

source "$SCRIPT_DIR/install.conf"

cp -R "$SCRIPT_DIR" "/home/$USERNAME/"
cp "$SCRIPT_DIR/install.conf" "/home/$USERNAME/$BASENAME/"
chown -R $USERNAME: "/home/$USERNAME/$BASENAME"
echo -ne "
--------------------------------------------------------------------
                    System ready for 2-install.sh
--------------------------------------------------------------------
"
