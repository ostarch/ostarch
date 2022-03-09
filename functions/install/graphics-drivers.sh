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
	if [ ! "$INSTALL_TYPE" = "minimal" ]; then
		nvidia_lts="nvidia-lts"
	fi
	pacman -S --noconfirm --needed nvidia $nvidia_lts nvidia-settings nvidia-utils lib32-nvidia-utils lib32-opencl-nvidia
	nvidia-xconfig
	echo "options nvidia_drm modeset=1" > /usr/lib/modprobe.d/nvidia-drm.conf
	#cp "$SCRIPT_DIR/nvidia.conf" "/etc/X11/xorg.conf.d/"
fi

if lspci | grep "VGA" | grep -Eq "Radeon|AMD"; then
	pacman -S --noconfirm --needed xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon
fi

if lspci | grep "VGA" | grep "Intel" | grep -q "Graphics"; then
	pacman -S --noconfirm --needed intel-media-driver libva-intel-driver libva-utils vulkan-intel lib32-vulkan-intel
fi