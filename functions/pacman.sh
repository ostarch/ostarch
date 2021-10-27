#!/usr/bin/env bash
#--------------------------------------------------------------------
#   █████╗ ██████╗  ██████╗██╗  ██╗██████╗  █████╗ ██╗   ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔══██╗██║   ██║██╔════╝
#  ███████║██████╔╝██║     ███████║██║  ██║███████║██║   ██║█████╗  
#  ██╔══██║██╔══██╗██║     ██╔══██║██║  ██║██╔══██║╚██╗ ██╔╝██╔══╝  
#  ██║  ██║██║  ██║╚██████╗██║  ██║██████╔╝██║  ██║ ╚████╔╝ ███████╗
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚══════╝
#--------------------------------------------------------------------

#Add ILoveCandy
if ! grep -q ILoveCandy "/etc/pacman.conf"; then
  sudo sed -i 's/^# Misc options/# Misc options\nILoveCandy/' pacman.conf
fi
#Add parallel downloading
sudo sed -i 's/^#Para/Para/' /etc/pacman.conf

#Add color
sudo sed -i 's/^#Color/Color/' /etc/pacman.conf

#Checks the available space
sudo sed -i 's/^#CheckSpace/CheckSpace/' /etc/pacman.conf

#Add parallel downloading
sudo sed -i 's/^#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf

#Enable multilib
sudo sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

