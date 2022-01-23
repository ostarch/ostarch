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

pacman -S --noconfirm --needed terminus-font
setfont ter-v22b
$SCRIPT_DIR/functions/pacman.sh
$SCRIPT_DIR/functions/mirrors.sh


echo -ne "
--------------------------------------------------------------------
                      Installing Prerequisites
--------------------------------------------------------------------
"
pacman -S --noconfirm --needed gptfdisk grub btrfs-progs xfsprogs dosfstools e2fsprogs

mkdir /mnt &>/dev/null
umount -R /mnt &>/dev/null
unset BOOT_PARTITION
unset ROOT_PARTITION

source "$SCRIPT_DIR/dialogs/mainmenu.sh"

if [[ -z "$BOOT_PARTITION" ]] || [[ -z "$ROOT_PARTITION" ]]; then
    $SCRIPT_DIR/functions/exit.sh
fi


# mount target
mount "$ROOT_PARTITION" /mnt
mkdir /mnt/boot
mkdir /mnt/boot/efi
mount "$BOOT_PARTITION" /mnt/boot/

if ! grep -qs '/mnt' /proc/mounts; then
    echo "Drive is not mounted, can not continue"
    $SCRIPT_DIR/functions/exit.sh
fi
echo -ne "
--------------------------------------------------------------------
                     Arch Install on Main Drive
--------------------------------------------------------------------
"
pacstrap /mnt base base-devel linux linux-firmware vim nano sudo archlinux-keyring wget git libnewt --noconfirm --needed
genfstab -U /mnt >> /mnt/etc/fstab
echo "keyserver hkp://keyserver.ubuntu.com" >> /mnt/etc/pacman.d/gnupg/gpg.conf
echo "DISK=$DISK" >> "$SCRIPT_DIR/install.conf"
cp -R "${SCRIPT_DIR}" /mnt/root
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
echo -ne "
--------------------------------------------------------------------
                 Checking for low memory systems <8G
--------------------------------------------------------------------
"
TOTALMEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
if [[  $TOTALMEM -lt 8000000 ]]; then
    # Put swap into the actual system, not into RAM disk, otherwise there is no point in it, it'll cache RAM into RAM. So, /mnt/ everything.
    mkdir /mnt/opt/swap # make a dir that we can apply NOCOW to to make it btrfs-friendly.
    chattr +C /mnt/opt/swap # apply NOCOW, btrfs needs that.
    dd if=/dev/zero of=/mnt/opt/swap/swapfile bs=1M count=2048 status=progress
    chmod 600 /mnt/opt/swap/swapfile # set permissions.
    chown root /mnt/opt/swap/swapfile
    mkswap /mnt/opt/swap/swapfile
    swapon /mnt/opt/swap/swapfile
    # The line below is written to /mnt/ but doesn't contain /mnt/, since it's just / for the system itself.
    echo "/opt/swap/swapfile	none	swap	sw	0	0" >> /mnt/etc/fstab # Add swap to fstab, so it KEEPS working after installation.
fi
echo -ne "
--------------------------------------------------------------------
                     System ready for 1-setup.sh
--------------------------------------------------------------------
"
