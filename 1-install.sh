#!/usr/bin/env bash
echo "****************************************************************"
echo "* 1 ____     _____   _______                            _      *"
echo "*  / __ \   / ____| |__   __|     /\                   | |     *"
echo "* | |  | | | (___      | |       /  \     _ __    ___  | |__   *"
echo "* | |  | |  \___ \     | |      / /\ \   | '__|  / __| | '_ \  *" 
echo "* | |__| |  ____) |    | |     / ____ \  | |    | (__  | | | | *"
echo "*  \____/  |_____/     |_|    /_/    \_\ |_|     \___| |_| |_| *"
echo "*                                                              *"
echo "****************************************************************"
echo "*******************************************************"
echo "* 1                                                   *"
echo "*       Arch Linux Pre-Install Setup and Config       *"
echo "*                                                     *"
echo "*******************************************************"

    SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )" # Get the value of Present Directory
    timedatectl set-ntp true
    sed -i 's/^#Parallel/Parallel/' /etc/pacman.conf                                  # Enable Parallel Downloads
    sed -i 's/^#Color/Color\nILoveCandy/' /etc/pacman.conf                            # Enable Color & ILoveCandy
    clear

# Mirrorlist Based on Country:
    echo "*******************************************************"
    echo "* 1    Select how you want to configure Mirrorlist    *"
    echo "*******************************************************"
    export iso=$(curl -4 ifconfig.co/country-iso) 
    PS3='Please Select How you want to generate mirrorlist: '
        options=("Fast 5 for $iso" "General" "Next-Step / Quit")
        select opt in "${options[@]}"
        do
            case $opt in
                "Fast 5 for $iso")
                    export isoc=1
                    break
                    ;;
                "General")
                    export isoc=2
                    break
                    ;;
                "Continue"|"Q"|"Quit"|*)
                    export isoc=3
                    break
                    ;;
                *) echo "invalid option $REPLY";;
            esac
        done

# Setting up mirrors for optimal download
    set -e
    if [ $isoc -eq 1 ] || [ $isoc -eq 2 ]; then
        echo "*******************************************************"
        echo "* 1     Setting up mirrors for optimal download       *"
        echo "*******************************************************"
        echo "****************************************************************"
        echo "* 1 ____     _____   _______                            _      *"
        echo "*  / __ \   / ____| |__   __|     /\                   | |     *"
        echo "* | |  | | | (___      | |       /  \     _ __    ___  | |__   *"
        echo "* | |  | |  \___ \     | |      / /\ \   | '__|  / __| | '_ \  *"
        echo "* | |__| |  ____) |    | |     / ____ \  | |    | (__  | | | | *"
        echo "*  \____/  |_____/     |_|    /_/    \_\ |_|     \___| |_| |_| *"
        echo "*                                                              *"
        echo "****************************************************************"
        pacman -S --noconfirm --needed reflector rsync
        cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup                     # Backup your mirrorlist
            if [ $isoc -eq 1 ]; then
                reflector -a 48 -c $iso -f 5 -l 20 --save /etc/pacman.d/mirrorlist      # Generate new mirrorlist
            elif [ $isoc -eq 2 ]; then
                reflector -a 48 -p https -l 20 --save /etc/pacman.d/mirrorlist          # Generate new mirrorlist
            fi
    fi
    clear


echo "*******************************************************"
echo "* 2                                                   *"
echo "*              Disk Partition & Mount                 *"
echo "*                                                     *"
echo "*******************************************************"
echo "*******************************************************"
echo "* 2                Disk Partition                     *"
echo "*******************************************************"
    PS3='Please Choose The Options Carefully: '
    options=("Run Partitioning Script Now" "Already Done Partitioning Earlier With THIS Script (Skip Partitioning)" "Quit / Next Step")
    select opt in "${options[@]}"
    do
        case $opt in
            "Run Partitioning Script Now")
                            clear
                            echo "*******************************************************"
                            echo "* 2        Choose Disk type you are using             *"
                            echo "*******************************************************"
                            PS2='Please Choose The Appropriate Disk Type: '
                            option=("Choose, If you are using Hard Disk (HDD)" "Choose, If you are using Nvme Drive (SSD)")
                            select opt in "${option[@]}"
                            do
                                case $opt in
                                    "Choose, If you are using Hard Disk (HDD)")
                                        export hd=1
                                        break
                                        ;;
                                    "Choose, If you are using Nvme Drive (SSD)")
                                        export hd=2
                                        break
                                        ;;
                                esac
                            done
                        echo "*******************************************************"
                        echo "* 2    Installing prerequisites for Partitioning      *"
                        echo "*******************************************************"
                        pacman -S --noconfirm --needed gptfdisk btrfs-progs
                        clear
                            echo "*******************************************************"
                            echo "* 2     How you want to partition your Drive          *"
                            echo "*******************************************************"
                        PS5='Please Select How You Want To Partition Your Hard-Drive:'
                        options=("Choose Root(/) & Boot Partition Manually and Format" "Erase Entire HDD/SSD and Create New Partitions (Auto)" "Quit")
                        select opt in "${options[@]}"
                        do
                            case $opt in
                                "Choose Root(/) & Boot Partition Manually and Format")
                                    clear
                                    echo "########################################################################################"
                                    echo "**************************************************************"
                                    echo "* 2     Please Note Down The Partition Names & Numbers       *"
                                    echo "**************************************************************"
                                    lsblk 
                                    echo "########################################################################################"
                                    echo "**********************************************************"
                                    echo "* 2              Custom-Partition                        *"
                                    echo "*________________________________________________________*"
                                    echo "* THIS WILL FORMAT AND DELETE ALL DATA ON THE PARTITIONS *"
                                    echo "**********************************************************"
                                    echo "Please Enter Your *EFI/SYS* Disk Name {example (/dev/sda) / (/dev/nvme0n1) -> Without Partition Number}"
                                    read EFI
                                    echo "Please Enter Your *ROOT* Disk Name {example (/dev/sda) / (/dev/nvme0n1) -> Without Partition Number}"
                                    read ROOT
                                    echo "Please Enter Your *EFI/SYS* Partition Number {example (1) / (p1) -> Partition Number Only}"
                                    read EFIn
                                    echo "Please Enter Your *ROOT* Partition Number {example (2) / (p2) -> Partition Number Only}"
                                    read ROOTn
                                    clear
                                    echo "*******************************************************"
                                    echo "* 2            Formatting Partitions...               *"
                                    echo "*******************************************************"
                                    # Initial Format
                                        partprobe ${EFI}
                                        partprobe ${ROOT}
                                        mkfs.vfat -F32 -n "EFI-ARCH" "${EFI}${EFIn}"
                                        mkfs.btrfs -f -L "ARCH" "${ROOT}${ROOTn}"
                                    # label partitions
                                        sgdisk -c $EFIn:"EFI-ARCH" ${EFI}
                                        sgdisk -c $ROOTn:"ARCH" ${ROOT}
                                    # setting partitions
                                    clear
                                    echo "-------------------------------------------------------"
                                    echo " 2             Creating Filesystems...                 "
                                    echo "-------------------------------------------------------"
                                        cryptsetup --type luks1 -v -y luksFormat ${ROOT}${ROOTn}
                                        cryptsetup open ${ROOT}${ROOTn} cryptdev
                                        mkfs.vfat -F32 -n "EFI-ARCH" "${EFI}${EFIn}"
                                        mkfs.btrfs -L "ARCH" /dev/mapper/cryptdev
                                        mount /dev/mapper/cryptdev /mnt                                  # Root Partition Temp Mount
                                    echo "*******************************************************"
                                    echo "* 2               Creating Subvolume                  *"
                                    echo "*******************************************************" 
                                        btrfs subvolume create /mnt/@                 
                                        btrfs subvolume create /mnt/@home
                                        btrfs subvolume create /mnt/@snapshots
                                        btrfs subvolume create /mnt/@cache
                                        btrfs subvolume create /mnt/@libvirt
                                        btrfs subvolume create /mnt/@log
                                        btrfs subvolume create /mnt/@tmp
                                    echo "*******************************************************"
                                    echo "* 2                 Mount Subvolume                   *"
                                    echo "*******************************************************" 
                                        umount /mnt
                                            export sv_opts="rw,noatime,compress-force=zstd:1,space_cache=v2"
                                        mount -o ${sv_opts},subvol=@ /dev/mapper/cryptdev /mnt
                                        mkdir -p /mnt/{home,.snapshots,var/cache,var/lib/libvirt,var/log,var/tmp}
                                        mount -o ${sv_opts},subvol=@home /dev/mapper/cryptdev /mnt/home
                                        mount -o ${sv_opts},subvol=@snapshots /dev/mapper/cryptdev /mnt/.snapshots
                                        mount -o ${sv_opts},subvol=@cache /dev/mapper/cryptdev /mnt/var/cache
                                        mount -o ${sv_opts},subvol=@libvirt /dev/mapper/cryptdev /mnt/var/lib/libvirt
                                        mount -o ${sv_opts},subvol=@log /dev/mapper/cryptdev /mnt/var/log
                                        mount -o ${sv_opts},subvol=@tmp /dev/mapper/cryptdev /mnt/var/tmp
                                        mkdir -p /mnt/boot/efi
                                        mount "${EFI}${EFIn}" /mnt/boot/
                                    export part=1
                                    export pa=1
                                    break
                                    ;;
                                "Erase Entire HDD/SSD and Create New Partitions (Auto)")
                                    clear
                                    lsblk
                                    echo "***********************************************************"
                                    echo "* 2                  Auto-Partition                       *"
                                    echo "*_________________________________________________________*"
                                    echo "*--> THIS WILL FORMAT AND DELETE ALL DATA ON THE DISK  <--*"
                                    echo "***********************************************************"
                                    echo "Please Enter Your Disk Name {example (/dev/sda) / (/dev/nvme0n1) -> Without Partition Number}"
                                    read disk
                                    clear
                                    echo "*******************************************************"
                                    echo "* 2              Formatting disk...                   *"
                                    echo "*******************************************************"
                                    # disk prep
                                        wipefs -af ${disk}                              # zap/Clean all on disk
                                        sgdisk --zap-all --clear ${disk}
                                        partprobe ${disk}   
                                    # create partitions
                                        sgdisk -n 1::+600M --typecode=1:ef00 --change-name=1:'EFI-ARCH' ${disk}  # partition 1 (UEFI Boot Partition) --fat32
                                        sgdisk -n 2::-0 --typecode=2:8300 --change-name=2:'ARCH' ${disk}    # partition 2 (Root), default start, remaining --ext4
                                        partprobe ${disk}
                                    # Value Assignment
                                        EFI=${disk}
                                        ROOT=${disk}
                                            if [ $hd -eq 1 ]; then
                                                EFIn=1
                                                ROOTn=2
                                            elif [ $hd -eq 2 ]; then
                                                EFIn=p1
                                                ROOTn=p2
                                            fi
                                       # label partitions
                                        sgdisk -c $EFIn:"EFI-ARCH" ${EFI}
                                        sgdisk -c $ROOTn:"ARCH" ${ROOT}
                                    # setting partitions
                                    clear
                                    echo "-------------------------------------------------------"
                                    echo " 2             Creating Filesystems...                 "
                                    echo "-------------------------------------------------------"
                                        cryptsetup --type luks1 -v -y luksFormat ${ROOT}${ROOTn}
                                        cryptsetup open ${ROOT}${ROOTn} cryptdev
                                        mkfs.vfat -F32 -n "EFI-ARCH" "${EFI}${EFIn}"
                                        mkfs.btrfs -L "ARCH" /dev/mapper/cryptdev
                                        mount /dev/mapper/cryptdev /mnt                                  # Root Partition Temp Mount
                                    echo "*******************************************************"
                                    echo "* 2               Creating Subvolume                  *"
                                    echo "*******************************************************" 
                                        btrfs subvolume create /mnt/@                 
                                        btrfs subvolume create /mnt/@home
                                        btrfs subvolume create /mnt/@snapshots
                                        btrfs subvolume create /mnt/@cache
                                        btrfs subvolume create /mnt/@libvirt
                                        btrfs subvolume create /mnt/@log
                                        btrfs subvolume create /mnt/@tmp
                                    echo "*******************************************************"
                                    echo "* 2                 Mount Subvolume                   *"
                                    echo "*******************************************************" 
                                        umount /mnt
                                            export sv_opts="rw,noatime,compress-force=zstd:1,space_cache=v2"
                                        mount -o ${sv_opts},subvol=@ /dev/mapper/cryptdev /mnt
                                        mkdir -p /mnt/{home,.snapshots,var/cache,var/lib/libvirt,var/log,var/tmp}
                                        mount -o ${sv_opts},subvol=@home /dev/mapper/cryptdev /mnt/home
                                        mount -o ${sv_opts},subvol=@snapshots /dev/mapper/cryptdev /mnt/.snapshots
                                        mount -o ${sv_opts},subvol=@cache /dev/mapper/cryptdev /mnt/var/cache
                                        mount -o ${sv_opts},subvol=@libvirt /dev/mapper/cryptdev /mnt/var/lib/libvirt
                                        mount -o ${sv_opts},subvol=@log /dev/mapper/cryptdev /mnt/var/log
                                        mount -o ${sv_opts},subvol=@tmp /dev/mapper/cryptdev /mnt/var/tmp
                                        mkdir -p /mnt/boot/efi
                                        mount "${EFI}${EFIn}" /mnt/boot/
                                    export part=1
                                    export pa=1
                                    break
                                    ;;
                                "Continue"|"Q"|"Quit"|*)
                                    export part=2
                                    export pa=1
                                    break
                                    ;;
                            esac                           
                        done
                clear
                lsblk
                break
                ;;
            "Already Done Partitioning Earlier With THIS Script (Skip Partitioning)")
                clear
                echo "########################################################################################"
                echo "**************************************************************"
                echo "* 2     Please Note Down The Partition Names & Numbers       *"
                echo "**************************************************************"
                lsblk 
                echo "########################################################################################"
                echo "**********************************************************"
                echo "* 2               Skip Partitioning                      *"
                echo "**********************************************************"
                echo "Please Enter Your *EFI/SYS* Disk Name {example (/dev/sda) / (/dev/nvme0n1) -> Without Partition Number}"
                read EFI
                echo "Please Enter Your *ROOT* Disk Name {example (/dev/sda) / (/dev/nvme0n1) -> Without Partition Number}"
                read ROOT
                echo "Please Enter Your *EFI/SYS* Partition Number {example (1) / (p1) -> Partition Number Only}"
                read EFIn
                echo "Please Enter Your *ROOT* Partition Number {example (2) / (p2) -> Partition Number Only}"
                read ROOTn
                clear
                export part=1
                export pa=2
                break
                ;;
            "Continue"|"Q"|"Quit"|*)
                export part=2
                export pa=1
                break
                ;;
        esac
    done

#"***********************************************************"
#"* 2      Mounting Partitions (without-format only)        *"
#"***********************************************************"
    set -e
    if [ $part -ne 1 ]; then
        echo "*******************************************************"
        echo "* 2  ERROR --> No Partitions Set for Installation     *"
        echo "*******************************************************"
        exit
    fi

    set -e
    if [ $pa -eq 2 ]; then
    echo "*******************************************************"
    echo "* 2             Mounting Partitions                   *"
    echo "*******************************************************"
        cryptsetup open ${ROOT}${ROOTn} cryptdev
            export sv_opts="rw,noatime,compress-force=zstd:1,space_cache=v2"
        mount -o ${sv_opts},subvol=@ /dev/mapper/cryptdev /mnt
        mount -o ${sv_opts},subvol=@home /dev/mapper/cryptdev /mnt/home
        mount -o ${sv_opts},subvol=@snapshots /dev/mapper/cryptdev /mnt/.snapshots
        mount -o ${sv_opts},subvol=@cache /dev/mapper/cryptdev /mnt/var/cache
        mount -o ${sv_opts},subvol=@libvirt /dev/mapper/cryptdev /mnt/var/lib/libvirt
        mount -o ${sv_opts},subvol=@log /dev/mapper/cryptdev /mnt/var/log
        mount -o ${sv_opts},subvol=@tmp /dev/mapper/cryptdev /mnt/var/tmp
        mount "${EFI}${EFIn}" /mnt/boot/
        lsblk
    fi


echo "*******************************************************"
echo "* 3                                                   *"
echo "*                   System-Install                    *"
echo "*                                                     *"
echo "*******************************************************"
# Main Install (Pacstrap). Skip, if Done Earlier:
    set -e
    if [[ $part -eq 1 ]] && [[ $pa -eq 1 ]]; then
    echo "*******************************************************"
    echo "* 3     Arch Linux Installation on Main Drive         *"
    echo "*_____________________________________________________*"
    echo "*******************************************************"
        #Microcode 1.17
        pacstrap /mnt base base-devel btrfs-progs linux linux-firmware bash-completion cryptsetup htop man-db mlocate neovim networkmanager pacman-contrib sudo terminus-font tmux --noconfirm --needed
        genfstab -U -p /mnt >> /mnt/etc/fstab
        echo "keyserver hkp://keyserver.ubuntu.com" >> /mnt/etc/pacman.d/gnupg/gpg.conf
    fi

    set -e
    if [[ $part -eq 1 ]] && [[ $pa -eq 2 ]]; then
        clear
        echo "*******************************************************"
        echo "* 3    Choose if you want to run Pacstrap again       *"
        echo "*******************************************************"
        PS2='Please Choose The Appropriate Option: '
        option=("Skip Pacstrap, Already done earlier" "Do Pacstrap Now, Not done earlier")
            select opt in "${option[@]}"
            do
            case $opt in
                "Skip Pacstrap, Already done earlier")
                    echo "Skipping Pacstrap"
                    break
                    ;;
                "Do Pacstrap Now, Not done earlier")
                    echo "*******************************************************"
                    echo "* 3     Arch Linux Installation on Main Drive         *"
                    echo "*_____________________________________________________*"
                    echo "*******************************************************"
                        #Microcode 1.17
                        pacstrap /mnt base base-devel btrfs-progs linux linux-firmware bash-completion cryptsetup htop man-db mlocate neovim networkmanager pacman-contrib sudo terminus-font tmux --noconfirm --needed
                        genfstab -U -p /mnt >> /mnt/etc/fstab
                        echo "keyserver hkp://keyserver.ubuntu.com" >> /mnt/etc/pacman.d/gnupg/gpg.conf
                    break
                    ;;
            esac
            done
    fi

# Swap File:
    # echo "-----------------------------------------------------"
    # echo "---------- Swap for systems with <8G RAM ------------"
    # echo "-----------------------------------------------------"
    TOTALMEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
    if [[  $TOTALMEM -lt 8000000 ]]; then
        clear
        echo "*******************************************************"
        echo "* 3       Do you want to create swap file?            *"
        echo "*******************************************************"
        PS2='Do you want to create Swap File: '
            option=("Yes, Create Swap File" "No, Skip Creating Swap file")
            select opt in "${option[@]}"
            do
                case $opt in
                    "Yes, Create Swap File")
                        if [[ ! -d "/mnt/opt/swap" ]]; then
                            echo "*******************************************************"
                            echo "* 3                Making Swap File                   *"
                            echo "*******************************************************"
                            #Put swap into the actual system, not into RAM disk, otherwise there is no point in it, it'll cache RAM into RAM. So, /mnt/ everything.
                            mkdir /mnt/opt/swap #make a dir that we can apply NOCOW to to make it btrfs-friendly.
                            chattr +C /mnt/opt/swap #apply NOCOW, btrfs needs that.
                            dd if=/dev/zero of=/mnt/opt/swap/swapfile bs=1M count=2048 status=progress
                            chmod 600 /mnt/opt/swap/swapfile #set permissions.
                            chown root /mnt/opt/swap/swapfile
                            mkswap /mnt/opt/swap/swapfile
                            swapon /mnt/opt/swap/swapfile
                            #The line below is written to /mnt/ but doesn't contain /mnt/, since it's just / for the sysytem itself.
                            echo "/opt/swap/swapfile	none	swap	sw	0	0" >> /mnt/etc/fstab #Add swap to fstab, so it KEEPS working after installation.
                            echo "*******************************************************"
                            echo "* 3                   Swap Done.                      *"
                            echo "*******************************************************"
                        fi
                        break
                        ;;
                    "No, Skip Creating Swap file")
                        echo "*******************************************************"
                        echo "* 3              Skipping Swap File                   *"
                        echo "*******************************************************"
                        break
                        ;;
                esac
            done
    fi

    cp -R ${SCRIPT_DIR} /mnt/root/                                                          # Copy Script to /root/ostarch/
    cp -R /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist                             # Mirrorlist to New Install