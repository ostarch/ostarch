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

source "$SCRIPT_DIR/functions/mirrors.sh"

nc="$(grep -c ^processor /proc/cpuinfo)"
nc2=$(expr $(expr $(grep -c ^processor /proc/cpuinfo) + 1) / 2)
echo -ne "
-------------------------------------------------------------------------
                          You have "$nc" cores.
			     Changing the makeflags for "$nc" cores.
			Changing the compression settings for "$nc" cores.
-------------------------------------------------------------------------
"
TOTALMEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
if [[  $TOTALMEM -gt 8000000 ]]; then
	sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j'"$nc2"'"/g' /etc/makepkg.conf
	sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T '"$nc2"' -z -)/g' /etc/makepkg.conf
fi

source "$SCRIPT_DIR/functions/locale.sh"

# Set keymaps
localectl --no-ask-password set-keymap us

# Add sudo no password rights
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

source "$SCRIPT_DIR/functions/pacman.sh"

# determine processor type and install microcode
if lscpu | grep "GenuineIntel"; then
    echo "Installing Intel microcode"
    pacman -S --noconfirm intel-ucode
    proc_ucode=intel-ucode.img
elif lscpu | grep "AuthenticAMD"; then
    echo "Installing AMD microcode"
    pacman -S --noconfirm amd-ucode
    proc_ucode=amd-ucode.img
fi

echo -ne "
-------------------------------------------------------------------------
                    Installing Graphics Drivers
-------------------------------------------------------------------------
"
# Graphics Drivers find and install
if lspci | grep -E "NVIDIA|GeForce"; then
	pacman -S nvidia nvidia-settings nvidia-utils lib32-nvidia-utils lib32-opencl-nvidia --noconfirm --needed
	nvidia-xconfig
	echo "options nvidia_drm modeset=1" > /usr/lib/modprobe.d/nvidia-drm.conf
	#cp "$SCRIPT_DIR/nvidia.conf" "/etc/X11/xorg.conf.d/"
fi
if lspci | grep 'VGA' | grep -E "Radeon|AMD"; then
	pacman -S xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon --noconfirm --needed
fi
if lspci | grep "VGA" | grep "Intel" | grep "Graphics"; then
	pacman -S libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils --needed --noconfirm
fi


echo -ne "
-------------------------------------------------------------------------
                    Installing Base System  
-------------------------------------------------------------------------
"
sed -e "/^#/d" -e "s/ #.*//" -e 's/ //g' ${SCRIPT_DIR}/packages/pacman.txt | pacman -S --needed --noconfirm -

echo -ne "
-------------------------------------------------------------------------
                    Installing Gaming Drivers
-------------------------------------------------------------------------
"
sed -e "/^#/d" -e "s/ #.*//" -e 's/ //g' ${SCRIPT_DIR}/packages/pacman-gaming.txt | pacman -S --needed --noconfirm -

if lspci | grep -E "NVIDIA|GeForce"; then
	pacman -S nvidia-lts --noconfirm --needed
fi

source "$SCRIPT_DIR/functions/adduser.sh"
source "$SCRIPT_DIR/functions/sethostname.sh"
cp -R "/root/$BASENAME" "/home/$USERNAME/$BASENAME"
chown -R $USERNAME: "/home/$USERNAME/$BASENAME"
echo -ne "
-------------------------------------------------------------------------
                    System ready for 2-user.sh
-------------------------------------------------------------------------
"