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
unset SWAP_PARTITION
unset SWAP_TYPE
unset HIBERNATE_TYPE

source "$SCRIPT_DIR/dialogs/mainmenu.sh"

if [[ -z "$BOOT_PARTITION" ]] || [[ -z "$ROOT_PARTITION" ]]; then
    source $SCRIPT_DIR/functions/exit.sh
fi


mount "$ROOT_PARTITION" /mnt
mkdir /mnt/boot &>/dev/null
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
pacstrap /mnt --noconfirm --needed base base-devel linux linux-firmware vim nano sudo archlinux-keyring wget git libnewt fprintd
if [[ "$SWAP_TYPE" == "file" ]]; then
    swapSize=$(getSwapSpace)
    if [[ "$swapSize" -gt 0 ]]; then
        if [ ! -f /mnt/swapfile ]; then
            echo
            echo "--------------------------------------------------------------------"
            echo "                         Creating Swap File                         "
            echo "--------------------------------------------------------------------"
            if [ "$(lsblk -plnf -o FSTYPE "$ROOT_PARTITION")" == 'btrfs' ]; then
                truncate -s 0 /mnt/swapfile
                chattr +C /mnt/swapfile
                btrfs property set /mnt/swapfile compression none
            fi
            dd if=/dev/zero of=/mnt/swapfile bs=1M count="$swapSize" status=progress
            chmod 600 /mnt/swapfile
            mkswap /mnt/swapfile
        fi
    fi
    swapon /mnt/swapfile
elif [[ -n "$SWAP_PARTITION" && "$SWAP_PARTITION" != "none" ]]; then
    swapon "$SWAP_PARTITION"
fi
echo "# <file system> <dir> <type> <options> <dump> <pass>" > /mnt/etc/fstab
genfstab -U /mnt >> /mnt/etc/fstab
echo "keyserver hkp://keyserver.ubuntu.com" >> /mnt/etc/pacman.d/gnupg/gpg.conf
echo "DISK=$DISK" >> "$SCRIPT_DIR/install.conf"
echo "BOOT_PARTITION=$BOOT_PARTITION" >> "$SCRIPT_DIR/install.conf"
echo "ROOT_PARTITION=$ROOT_PARTITION" >> "$SCRIPT_DIR/install.conf"
[ -n "$SWAP_PARTITION" ] && echo "SWAP_PARTITION=$SWAP_PARTITION" >> "$SCRIPT_DIR/install.conf"
[ -n "$SWAP_TYPE" ] && echo "SWAP_TYPE=$SWAP_TYPE" >> "$SCRIPT_DIR/install.conf"
[ -n "$HIBERNATE_TYPE" ] && echo "HIBERNATE_TYPE=$HIBERNATE_TYPE" >> "$SCRIPT_DIR/install.conf"
cp -R "${SCRIPT_DIR}" /mnt/root
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
echo -ne "
--------------------------------------------------------------------
                     System ready for 1-setup.sh
--------------------------------------------------------------------
"
