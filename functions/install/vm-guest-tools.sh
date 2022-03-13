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

virt=$(systemd-detect-virt)
if [ ! "$virt" = "none" ]; then
    echo "Installing QEMU guest tools"
    sudo pacman -S --noconfirm --needed qemu-guest-agent spice-vdagent
    sudo systemctl enable qemu-guest-agent.service
fi

if [ "$virt" = "oracle" ]; then
    echo "Installing VirtualBox guest tools"
    sudo pacman -S --noconfirm --needed virtualbox-guest-utils
    sudo systemctl enable vboxservice.service
elif [ "$virt" = "vmware" ]; then
    echo "Installing VMware tools"
    sudo pacman -S --noconfirm --needed open-vm-tools
    sudo systemctl enable vmtoolsd.service
    sudo systemctl enable vmware-vmblock-fuse.service
fi