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

echo -ne "
--------------------------------------------------------------------
                     Installing Graphics Drivers
--------------------------------------------------------------------
"

if lspci | grep -Eq "NVIDIA|GeForce"; then
	nvidia_lts=""
	source "$CURRENT_DIR/../../install.conf" &> /dev/null
	if [ ! "$INSTALL_TYPE" = "minimal" ] || pacman -Qi linux-lts &>/dev/null; then
		nvidia_lts="nvidia-lts"
	fi
	pacman -S --noconfirm --needed nvidia $nvidia_lts nvidia-settings nvidia-utils lib32-nvidia-utils
	echo "options nvidia_drm modeset=1" > /usr/lib/modprobe.d/nvidia-drm.conf
	! grep -q "MANGOHUD=1" /etc/environment && echo "MANGOHUD=1" >> /etc/environment
	#cp "$SCRIPT_DIR/nvidia.conf" "/etc/X11/xorg.conf.d/"
fi

if lspci | grep "VGA" | grep -Eq "Radeon|AMD"; then
	pacman -S --noconfirm --needed xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon radeontop
fi

if lspci | grep "VGA" | grep "Intel" | grep -q "Graphics"; then
	pacman -S --noconfirm --needed intel-media-driver libva-intel-driver lib32-libva-intel-driver vulkan-intel lib32-vulkan-intel intel-gpu-tools
fi

$CURRENT_DIR/vm-guest-tools.sh