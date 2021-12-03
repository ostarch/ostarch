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

echo "-------------------------------------"
echo "            Network Setup            "
echo "-------------------------------------"
pacman -S networkmanager dhclient --noconfirm --needed
systemctl enable --now NetworkManager

source "$SCRIPT_DIR/functions/mirrors.sh"

nc="$(grep -c ^processor /proc/cpuinfo)"
nc2=$(expr $(expr $(grep -c ^processor /proc/cpuinfo) + 1) / 2)
echo "You have "$nc" cores."
echo "-------------------------------------------------"
echo "Changing the makeflags for "$nc" cores."
TOTALMEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
if [[  $TOTALMEM -gt 8000000 ]]; then
	sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j'"$nc2"'"/g' /etc/makepkg.conf
	echo "Changing the compression settings for "$nc" cores."
	sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T '"$nc2"' -z -)/g' /etc/makepkg.conf
fi

source "$SCRIPT_DIR/functions/locale.sh"

# Set keymaps
localectl --no-ask-password set-keymap us

# Add sudo no password rights
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

source "$SCRIPT_DIR/functions/pacman.sh"

echo -e "\nInstalling Base System\n"

sed -e "/^#/d" -e "s/ #.*//" -e 's/ //g' ${SCRIPT_DIR}/packages/pacman.txt | pacman -S --needed --noconfirm -

#
# determine processor type and install microcode
# 
proc_type=$(lscpu | awk '/Vendor ID:/ {print $3}')
case "$proc_type" in
	GenuineIntel)
		print "Installing Intel microcode"
		pacman -S --noconfirm intel-ucode
		proc_ucode=intel-ucode.img
		;;
	AuthenticAMD)
		print "Installing AMD microcode"
		pacman -S --noconfirm amd-ucode
		proc_ucode=amd-ucode.img
		;;
esac	

# Graphics Drivers find and install
if lspci | grep -E "NVIDIA|GeForce"; then
	pacman -S nvidia nvidia-settings --noconfirm --needed
	nvidia-xconfig
	#cp "$SCRIPT_DIR/nvidia.conf" "/etc/X11/xorg.conf.d/"
fi
if lspci | grep -E "Radeon|AMD"; then
	pacman -S xf86-video-amdgpu --noconfirm --needed
fi
if lspci | grep -E "Integrated Graphics Controller"; then
	pacman -S libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils --needed --noconfirm
fi

echo -e "\nDone!\n"

read -p "Please enter username: " username
until (useradd -m -N -G wheel,libvirt -s /bin/bash "$username"); do
	read -p "Please enter username: " username
done
until (passwd "$username"); do : ; done
grpck
echo "username=$username" >> "$SCRIPT_DIR/install.conf"
cp -R "/root/$BASENAME" /home/$username/
chown -R $username: /home/$username/$BASENAME
read -p "Please name your machine: " nameofmachine
echo "$nameofmachine" > /etc/hostname