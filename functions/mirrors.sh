#!/usr/bin/env bash
#--------------------------------------------------------------------
#   █████╗ ██████╗  ██████╗██╗  ██╗██████╗  █████╗ ██╗   ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔══██╗██║   ██║██╔════╝
#  ███████║██████╔╝██║     ███████║██║  ██║███████║██║   ██║█████╗  
#  ██╔══██║██╔══██╗██║     ██╔══██║██║  ██║██╔══██║╚██╗ ██╔╝██╔══╝  
#  ██║  ██║██║  ██║╚██████╗██║  ██║██████╔╝██║  ██║ ╚████╔╝ ███████╗
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚══════╝
#--------------------------------------------------------------------
CURRENT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $CURRENT_DIR/../install.conf &>/dev/null

if [ "$SKIP_MIRRORS" = true ]; then
  exit
fi
packageList="pacman-contrib glibc curl rsync reflector"
for packageName in $packageList; do
  sudo pacman -Qq | grep -qw $packageName || sudo pacman -S --noconfirm --needed $packageName
done
iso=$(curl -4 ifconfig.co/country-iso)
sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
echo -ne "
--------------------------------------------------------------------
   █████╗ ██████╗  ██████╗██╗  ██╗██████╗  █████╗ ██╗   ██╗███████╗
  ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔══██╗██║   ██║██╔════
  ███████║██████╔╝██║     ███████║██║  ██║███████║██║   ██║█████╗  
  ██╔══██║██╔══██╗██║     ██╔══██║██║  ██║██╔══██║╚██╗ ██╔╝██╔══╝ 
  ██║  ██║██║  ██║╚██████╗██║  ██║██████╔╝██║  ██║ ╚████╔╝ ███████╗
  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚══════╝
--------------------------------------------------------------------
             Setting up $iso mirrors for faster downloads            
--------------------------------------------------------------------
"
sudo reflector -c "$iso" --score 10 -a 12 -p "https,http" --save /etc/pacman.d/mirrorlist && \
sudo reflector -c "Germany,Netherlands,Italy,France" --score 10 -a 12 -p "https,http" --sort country --save /tmp/mirrorlist && \
cat /tmp/mirrorlist | sudo tee -a /etc/pacman.d/mirrorlist &>/dev/null && \
sudo sed -i '/^#/d' /etc/pacman.d/mirrorlist && \
rankmirrors /etc/pacman.d/mirrorlist | sudo tee /etc/pacman.d/mirrorlist &>/dev/null && \
echo "SKIP_MIRRORS=true" >> $CURRENT_DIR/../install.conf
