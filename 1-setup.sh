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

    timedatectl set-ntp true
    sed -i 's/^#Parallel/Parallel/' /etc/pacman.conf                            # Enable Parallel Downloads
    sed -i 's/^#Color/Color\nILoveCandy/' /etc/pacman.conf                      # Enable Color & ILoveCandy
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