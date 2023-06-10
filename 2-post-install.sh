#!/usr/bin/env bash
clear
echo "****************************************************************"
echo "* 2 ____     _____   _______                            _      *"
echo "*  / __ \   / ____| |__   __|     /\                   | |     *"
echo "* | |  | | | (___      | |       /  \     _ __    ___  | |__   *"
echo "* | |  | |  \___ \     | |      / /\ \   | '__|  / __| | '_ \  *" 
echo "* | |__| |  ____) |    | |     / ____ \  | |    | (__  | | | | *"
echo "*  \____/  |_____/     |_|    /_/    \_\ |_|     \___| |_| |_| *"
echo "*                                                              *"
echo "****************************************************************"
echo "*******************************************************"
echo "* 4          GRUB-Bootloader Install (EFI)            *"
echo "*                                                     *"
echo "*******************************************************"

    if [[ -d "/sys/firmware/efi" ]]; then                             # Valid
        pacman -S grub efibootmgr efivar os-prober ntfs-3g --noconfirm --needed
        #export bkidd=$(blkid -s UUID -o value ${ROOT}${ROOTn})
        #sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet cryptdevice=UUID=${bkidd}:cryptdev"/' /etc/default/grub
        #grub-install --target
        #grub-mkconfig -o /boot/grub/grub.cfg
    fi