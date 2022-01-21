#!/usr/bin/env bash
#--------------------------------------------------------------------
#   █████╗ ██████╗  ██████╗██╗  ██╗██████╗  █████╗ ██╗   ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔══██╗██║   ██║██╔════╝
#  ███████║██████╔╝██║     ███████║██║  ██║███████║██║   ██║█████╗  
#  ██╔══██║██╔══██╗██║     ██╔══██║██║  ██║██╔══██║╚██╗ ██╔╝██╔══╝  
#  ██║  ██║██║  ██║╚██████╗██║  ██║██████╔╝██║  ██║ ╚████╔╝ ███████╗
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚══════╝
#--------------------------------------------------------------------

[ "$(id -u)" = "0" ] || exec sudo "$0" "$@"

#Add ILoveCandy
if ! grep -q ILoveCandy "/etc/pacman.conf"; then
  sed -i 's/^# Misc options/# Misc options\nILoveCandy/' /etc/pacman.conf
fi
#Add parallel downloading
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

#Add color
sed -i 's/^#Color/Color/' /etc/pacman.conf

#Checks the available space
sed -i 's/^#CheckSpace/CheckSpace/' /etc/pacman.conf

#Add parallel downloading
sed -i 's/^#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf

#Enable multilib
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

pacman -Sy --noconfirm