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
echo "You have " $nc" cores."
echo "-------------------------------------------------"
echo "Changing the makeflags for "$nc" cores."
TOTALMEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
if [[  $TOTALMEM -gt 8000000 ]]; then
	sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j'"$nc2"'"/g' /etc/makepkg.conf
	echo "Changing the compression settings for "$nc" cores."
	sudo sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T '"$nc2"' -z -)/g' /etc/makepkg.conf
fi

source "$SCRIPT_DIR/functions/locale.sh"

# Set keymaps
localectl --no-ask-password set-keymap us

# Add sudo no password rights
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

source "$SCRIPT_DIR/functions/pacman.sh"

echo -e "\nInstalling Base System\n"

PKGS=(
'mesa' # Essential Xorg First
'xorg'
'xorg-server'
'xorg-apps'
'xorg-drivers'
'xorg-xkill'
'xorg-xinit'
'xterm'
'plasma-desktop' # KDE Load second
'alsa-plugins' # audio plugins
'alsa-utils' # audio utils
'ark' # compression
'audiocd-kio' 
'autoconf' # build
'automake' # build
'barrier'
'base'
'bash-completion'
'bind'
'binutils'
'bison'
'bluedevil'
'bluez'
'bluez-libs'
'bluez-utils'
'breeze'
'breeze-gtk'
'bridge-utils'
'btrfs-progs'
'celluloid' # video players
'cmatrix'
'code' # Visual Studio code
'cronie'
'cups'
'cups-pdf'
'dialog'
'discord'
'dolphin'
'dolphin-plugins'
'dosfstools'
'efibootmgr' # EFI boot
'egl-wayland'
'evolution'
'exfat-utils'
'extra-cmake-modules'
'filelight'
'firefox'
'flameshot'
'flex' # recognize lexical patterns in text
'fuse2'
'fuse3'
'fuseiso'
'gamemode'
'gcc'
'gimp' # Photo editing
'git'
'gptfdisk'
'gradle'
'grub'
'grub-customizer'
'gst-libav'
'gst-plugins-good'
'gst-plugins-ugly'
'gutenprint'
'gwenview'
'haveged'
'htop'
'hunspell'
'hunspell-en_us'
'hunspell-de'
#'iptables-nft'
'jdk-openjdk' # Java 17
'kate'
'kcalc'
'kcharselect'
'kcodecs'
'kcoreaddons'
'kcrash'
'kcron'
'kde-gtk-config'
'kdeconnect'
'konsole'
'kdenetwork-filesharing'
'kdenlive'
'kdeplasma-addons'
'kdialog'
'keychain'
'kfind'
'kgamma5'
'kgpg'
'khotkeys'
'kinfocenter'
'kmenuedit'
'kompare'
'konsole'
'krdc'
'kscreen'
'ksystemlog'
'ksysguard'
'ktorrent'
'kwallet'
'kwallet-pam'
'layer-shell-qt'
'libappindicator-gtk3'
'libindicator-gtk2'
'libindicator-gtk3'
'libnewt'
'libreoffice-still'
'libreoffice-still-de'
'libtool'
'libvncserver'
'linux'
'linux-firmware'
'linux-headers'
'linux-lts'
'linux-lts-headers'
'lsof'
'lutris'
'lzop'
'm4'
'make'
'man-db'
'man-pages'
'milou' # alternative to KRunner
'nano'
'ncdu'
'neofetch'
'neovim'
'net-tools'
'networkmanager'
'networkmanager-openconnect'
'networkmanager-openvpn'
'networkmanager-vpnc'
'nfs-utils'
'nmap'
'npm'
'ntfs-3g'
'ntp'
'obs-studio'
'okular'
'openbsd-netcat'
'openssh'
'os-prober'
'oxygen'
'p7zip'
'pacman-contrib'
'partitionmanager'
'patch'
'pavucontrol'
'php-cgi'
'php7'
'php7-apache'
'php7-cgi'
'php7-gd'
'picom'
'pkgconf'
'plasma-browser-integration'
'plasma-disks'
'plasma-firewall'
'plasma-nm'
'plasma-pa'
'plasma-thunderbolt'
'plasma-vault'
'powerline-fonts'
'powertop'
'print-manager'
'pulseaudio'
'pulseaudio-alsa'
'pulseaudio-bluetooth'
'python-notify2'
'python-psutil'
'python-pyqt5'
'python-pip'
'qemu'
'qemu-arch-extra'
'remmina'
'rsync'
'screen'
'scrot'
'sddm'
'sddm-kcm'
'shellcheck'
'simple-scan'
'simplescreenrecorder'
#'snapper'
#'spectacle'
'speedtest-cli'
'steam'
'stow'
'sudo'
'swtpm'
'systemsettings'
'terminus-font'
'tesseract'
'tesseract-data-deu'
'tesseract-data-eng'
'texinfo'
'thunderbird'
'thunderbird-i18n-de'
'thunderbird-i18n-en-us'
'traceroute'
'tree'
'ufw'
'unrar'
'unzip'
'usbutils'
'vi'
'vim'
'virt-manager'
'virt-viewer'
'vlc'
'wget'
'which'
'wine'
'wine-gecko'
'wine-mono'
'winetricks'
'wireguard-tools'
'wireless_tools'
'wireshark-qt'
'xdg-desktop-portal-kde'
'xdg-user-dirs'
'xdotool'
'xsel'
'zeroconf-ioslave'
'zip'
'zsh'
'zsh-syntax-highlighting'
'zsh-autosuggestions'
)

for PKG in "${PKGS[@]}"; do
    echo "INSTALLING: ${PKG}"
    sudo pacman -S "$PKG" --noconfirm --needed
done

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
	#cp "$HOME/ArchDave/nvidia.conf" "/etc/X11/xorg.conf.d/"
fi
if lspci | grep -E "Radeon"; then
	pacman -S xf86-video-amdgpu --noconfirm --needed
fi
if lspci | grep -E "Integrated Graphics Controller"; then
	pacman -S libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils --needed --noconfirm
fi

echo -e "\nDone!\n"
if ! source install.conf &>/dev/null; then
	read -p "Please enter username: " username
echo "username=$username" >> "$SCRIPT_DIR/install.conf"
fi
if [ $(whoami) = "root"  ];
then
	useradd -m -G wheel,libvirt -s /bin/bash $username
	passwd $username
	cp -R "/root/$BASENAME" /home/$username/
	chown -R $username: /home/$username/$BASENAME
	read -p "Please name your machine:" nameofmachine
	echo $nameofmachine > /etc/hostname
else
	echo "You are already a user proceed with aur installs"
fi

