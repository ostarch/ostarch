#!/bin/bash
#--------------------------------------------------------------------
#   ██████╗ ███████╗████████╗     █████╗ ██████╗  ██████╗██╗  ██╗
#  ██╔═══██╗██╔════╝╚══██╔══╝    ██╔══██╗██╔══██╗██╔════╝██║  ██║
#  ██║   ██║███████╗   ██║       ███████║██████╔╝██║     ███████║
#  ██║   ██║╚════██║   ██║       ██╔══██║██╔══██╗██║     ██╔══██║
#  ╚██████╔╝███████║   ██║       ██║  ██║██║  ██║╚██████╗██║  ██║
#   ╚═════╝ ╚══════╝   ╚═╝       ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝
#--------------------------------------------------------------------
CURRENT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

if lscpu | grep -q "GenuineIntel"; then
    echo "Installing Intel microcode"
    pacman -S --noconfirm --needed intel-ucode
elif lscpu | grep -q "AuthenticAMD"; then
    echo "Installing AMD microcode"
    pacman -S --noconfirm --needed amd-ucode
fi