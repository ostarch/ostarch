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

$SCRIPT_DIR/functions/pacman.sh

pacman -S --noconfirm --needed terminus-font
setfont ter-v22b

echo -ne "
--------------------------------------------------------------------
                      Installing Prerequisites
--------------------------------------------------------------------
"
pacman -S --noconfirm --needed archlinux-keyring gptfdisk grub btrfs-progs xfsprogs dosfstools e2fsprogs

mkdir /mnt &>/dev/null
swapoff -a &>/dev/null
umount -R /mnt &>/dev/null
unset BOOT_PARTITION
unset ROOT_PARTITION

source "$SCRIPT_DIR/dialogs/mainmenu.sh"

if [[ -z "$BOOT_PARTITION" ]] || [[ -z "$ROOT_PARTITION" ]]; then
    source $SCRIPT_DIR/functions/exit.sh
fi


# mount target
mount "$ROOT_PARTITION" /mnt
mkdir /mnt/boot
mkdir /mnt/boot/efi
mount "$BOOT_PARTITION" /mnt/boot/

if ! grep -qs '/mnt' /proc/mounts; then
    echo "Drive is not mounted, can not continue"
    source $SCRIPT_DIR/functions/exit.sh
fi

$SCRIPT_DIR/functions/mirrors.sh

echo -ne "
--------------------------------------------------------------------
                     Arch Install on Main Drive
--------------------------------------------------------------------
"
pacstrap /mnt base base-devel linux linux-firmware vim nano sudo archlinux-keyring wget git libnewt --noconfirm --needed
TOTALMEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
if [[ $TOTALMEM -lt 8000000 ]]; then
    if [ ! -f /mnt/opt/swap/swapfile ]; then
        echo
        echo "--------------------------------------------------------------------"
        echo "                         Creating Swap File                         "
        echo "--------------------------------------------------------------------"
        mkdir /mnt/opt/swap # make a dir that we can apply NOCOW to to make it btrfs-friendly.
        truncate -s 0 /mnt/opt/swap/swapfile
        chattr +C /mnt/opt/swap/swapfile # apply NOCOW, btrfs needs that.
        btrfs property set /mnt/opt/swap/swapfile compression none
        dd if=/dev/zero of=/mnt/opt/swap/swapfile bs=1M count=2048 status=progress
        chmod 600 /mnt/opt/swap/swapfile
        mkswap /mnt/opt/swap/swapfile
    fi
    swapon /mnt/opt/swap/swapfile &>/dev/null
fi
echo "# <file system> <dir> <type> <options> <dump> <pass>" > /mnt/etc/fstab
genfstab -U /mnt >> /mnt/etc/fstab
echo "keyserver hkp://keyserver.ubuntu.com" >> /mnt/etc/pacman.d/gnupg/gpg.conf
echo "DISK=$DISK" >> "$SCRIPT_DIR/install.conf"
echo "BOOT_PARTITION=$BOOT_PARTITION" >> "$SCRIPT_DIR/install.conf"
echo "ROOT_PARTITION=$ROOT_PARTITION" >> "$SCRIPT_DIR/install.conf"
cp -R "${SCRIPT_DIR}" /mnt/root
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
echo -ne "
--------------------------------------------------------------------
                     System ready for 1-setup.sh
--------------------------------------------------------------------
"
