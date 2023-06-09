#!/usr/bin/env bash
echo "*******************************************************"
echo "* 2                                                   *"
echo "*              Disk Partition & Mount                 *"
echo "*                                                     *"
echo "*******************************************************"
echo "*******************************************************"
echo "* 2                Disk Partition                     *"
echo "*******************************************************"
    PS4='Please Choose The Options Carefully: '
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
                                        hd=1
                                        break
                                        ;;
                                    "Choose, If you are using Nvme Drive (SSD)")
                                        hd=2
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
                                    part=1
                                    pa=1
                                    BsInst=1
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
                                    part=1
                                    pa=1
                                    BsInst=1
                                    break
                                    ;;
                                "Continue"|"Q"|"Quit"|*)
                                    part=2
                                    pa=1
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
                part=1
                pa=2
                break
                ;;
            "Continue"|"Q"|"Quit"|*)
                part=2
                pa=1
                break
                ;;
        esac
    done

#"*******************************************************"
#"* 2    Mounting Partitions (without-format only)      *"
#"*******************************************************"
    if [ $part -ne 1 ]; then
        echo "*******************************************************"
        echo "* 2  ERROR --> No Partitions Set for Installation     *"
        echo "*******************************************************"
    fi

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