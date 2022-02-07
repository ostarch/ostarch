#!/bin/bash
#--------------------------------------------------------------------
#   █████╗ ██████╗  ██████╗██╗  ██╗██████╗  █████╗ ██╗   ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔══██╗██║   ██║██╔════╝
#  ███████║██████╔╝██║     ███████║██║  ██║███████║██║   ██║█████╗  
#  ██╔══██║██╔══██╗██║     ██╔══██║██║  ██║██╔══██║╚██╗ ██╔╝██╔══╝  
#  ██║  ██║██║  ██║╚██████╗██║  ██║██████╔╝██║  ██║ ╚████╔╝ ███████╗
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚══════╝
#--------------------------------------------------------------------
[ "$(id -u)" = "0" ] || exec sudo "$0" "$@"
CURRENT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cp -an /etc/default/grub /etc/default/grub.bak
sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT="Advanced options for Arch Linux>Arch Linux, with Linux linux"/' /etc/default/grub
sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT="1"/' /etc/default/grub
sed -i 's/quiet splash/text/' /etc/default/grub
sed -i 's/quiet/text/' /etc/default/grub

sed -i 's/^GRUB_DISABLE_RECOVERY=.*/GRUB_DISABLE_RECOVERY="false"/' /etc/default/grub

sed -i 's/GRUB_INIT_TUNE=.*/GRUB_INIT_TUNE="1750 523 1 392 1 523 1 659 1 784 1 1047 1 784 1 415 1 523 1 622 1 831 1 622 1 831 1 1046 1 1244 1 1661 1 1244 1 466 1 587 1 698 1 932 1 1195 1 1397 1 1865 1 1397 1"/' /etc/default/grub
sed -i 's/#GRUB_INIT_TUNE/GRUB_INIT_TUNE/' /etc/default/grub

sed -i 's/GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER="false"/' /etc/default/grub
sed -i 's/#GRUB_DISABLE_OS_PROBER/GRUB_DISABLE_OS_PROBER/' /etc/default/grub
if ! grep -q "GRUB_DISABLE_OS_PROBER=\"false\"" /etc/default/grub; then
  echo "GRUB_DISABLE_OS_PROBER=\"false\"" | tee -a /etc/default/grub > /dev/null
fi

$CURRENT_DIR/../stylish-grub-theme/install.sh

grub-mkconfig -o /boot/grub/grub.cfg