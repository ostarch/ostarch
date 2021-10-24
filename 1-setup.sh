#!/usr/bin/env bash
#-------------------------------------------------------------------------
#   █████╗ ██████╗  ██████╗██╗  ██╗████████╗██╗████████╗██╗   ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝██║  ██║╚══██╔══╝██║╚══██╔══╝██║   ██║██╔════╝
#  ███████║██████╔╝██║     ███████║   ██║   ██║   ██║   ██║   ██║███████╗
#  ██╔══██║██╔══██╗██║     ██╔══██║   ██║   ██║   ██║   ██║   ██║╚════██║
#  ██║  ██║██║  ██║╚██████╗██║  ██║   ██║   ██║   ██║   ╚██████╔╝███████║
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝   ╚═╝    ╚═════╝ ╚══════╝
#-------------------------------------------------------------------------
echo "--------------------------------------"
echo "--          Network Setup           --"
echo "--------------------------------------"
pacman -S networkmanager dhclient --noconfirm --needed
systemctl enable --now NetworkManager
echo "-------------------------------------------------"
echo "Setting up mirrors for optimal download          "
echo "-------------------------------------------------"
pacman -S --noconfirm pacman-contrib curl
pacman -S --noconfirm reflector rsync
iso=$(curl -4 ifconfig.co/country-iso)
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

nc=$(expr $(expr $(grep -c ^processor /proc/cpuinfo) + 1) / 2)
if [ "$nc" -eq "0" ]; then
	nc=1
fi
echo "You have " $nc" cores."
echo "-------------------------------------------------"
echo "Changing the makeflags for "$nc" cores."
sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j$nc"/g' /etc/makepkg.conf
echo "Changing the compression settings for "$nc" cores."
sudo sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T $nc -z -)/g' /etc/makepkg.conf

echo "-------------------------------------------------"
echo "       Setup Language to US and set locale       "
echo "-------------------------------------------------"
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
timedatectl --no-ask-password set-timezone Europe/Berlin
timedatectl --no-ask-password set-ntp 1
localectl --no-ask-password set-locale LANG="en_US.UTF-8" LC_COLLATE="" LC_TIME="en_US.UTF-8"

# Set keymaps
localectl --no-ask-password set-keymap us

# Add sudo no password rights
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

#Add parallel downloading
sed -i 's/^#Para/Para/' /etc/pacman.conf

#Enable multilib
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
pacman -Sy --noconfirm

echo -e "\nInstalling Base System\n"

PKGS=(
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
'dhcpcd'
'dialog'
'discord'
'dmidecode'
'dnsmasq'
'dolphin'
'dolphin-plugins'
'dosfstools'
'drkonqi'
'edk2-ovmf'
'efibootmgr' # EFI boot
'egl-wayland'
'evolution'
'exfat-utils'
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
'groff'
'grub'
'grub-customizer'
'gst-libav'
'gst-plugins-good'
'gst-plugins-ugly'
'gutenprint'
'gwenview'
'haveged'
'htop'
#'iptables-nft'
'jdk-openjdk' # Java 17
'kactivitymanagerd'
'kate'
'kcalc'
'kcharselect'
'kcron'
'kde-cli-tools'
'kde-gtk-config'
'kdeconnect'
'kdecoration'
'kdenetwork-filesharing'
'kdenlive'
'kdeplasma-addons'
'kdesdk-thumbnailers'
'kdialog'
'keychain'
'kfind'
'kgamma5'
'kgpg'
'khotkeys'
'kinfocenter'
'kmenuedit'
#'kmix'
'kompare'
'konsole'
'krdc'
'kscreen'
'kscreenlocker'
'ksshaskpass'
'ksysguard'
'ksystemlog'
'ksystemstats'
'ktorrent'
'kwallet-pam'
'kwalletmanager'
'kwayland-integration'
'kwayland-server'
'kwin'
'kwrite'
'kwrited'
'layer-shell-qt'
'libappindicator-gtk3'
'libindicator-gtk2'
'libindicator-gtk3'
'libguestfs'
'libkscreen'
'libksysguard'
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
'plasma-desktop'
'plasma-disks'
'plasma-firewall'
'plasma-integration'
'plasma-nm'
'plasma-pa'
'plasma-sdk'
'plasma-systemmonitor'
'plasma-thunderbolt'
'plasma-vault'
'plasma-wayland-session'
'plasma-workspace'
'plasma-workspace-wallpapers'
'polkit-kde-agent'
'powerdevil'
'powerline-fonts'
'powertop'
'print-manager'
'pulseaudio'
'pulseaudio-alsa'
'pulseaudio-bluetooth'
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
'vde2'
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
'xorg'
'xorg-server'
'xorg-xinit'
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
fi
if lspci | grep -E "Radeon"; then
    pacman -S xf86-video-amdgpu --noconfirm --needed
fi
if lspci | grep -E "Integrated Graphics Controller"; then
    pacman -S libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils --needed --noconfirm
fi

echo -e "\nDone!\n"
if ! source install.conf; then
	read -p "Please enter username:" username
echo "username=$username" >> ${HOME}/ArchDave/install.conf
fi
if [ $(whoami) = "root"  ];
then
	useradd -m -G wheel,libvirt -s /bin/bash $username
	passwd $username
	cp -R /root/ArchDave /home/$username/
	chown -R $username: /home/$username/ArchDave
else
	echo "You are already a user proceed with aur installs"
fi

