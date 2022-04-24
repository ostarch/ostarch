#!/bin/bash
#--------------------------------------------------------------------
#   █████╗ ██████╗  ██████╗██╗  ██╗██████╗  █████╗ ██╗   ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔══██╗██║   ██║██╔════╝
#  ███████║██████╔╝██║     ███████║██║  ██║███████║██║   ██║█████╗  
#  ██╔══██║██╔══██╗██║     ██╔══██║██║  ██║██╔══██║╚██╗ ██╔╝██╔══╝  
#  ██║  ██║██║  ██║╚██████╗██║  ██║██████╔╝██║  ██║ ╚████╔╝ ███████╗
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚══════╝
#--------------------------------------------------------------------
[ "$(id -u)" = "0" ] || exec sudo "$0" "$@"

nc="$(grep -c ^processor /proc/cpuinfo)"
echo -ne "
--------------------------------------------------------------------
                          You have $nc cores
                 Changing the makeflags for $nc cores
           Changing the compression settings for $nc cores
--------------------------------------------------------------------
"
sed -i 's/MAKEFLAGS=.*/MAKEFLAGS="-j'"$nc"'"/g' /etc/makepkg.conf
sed -i 's/#MAKEFLAGS/MAKEFLAGS/' /etc/makepkg.conf
sed -i 's/COMPRESSXZ=.*/COMPRESSXZ=(xz -c -z --threads='"$nc"' -)/g' /etc/makepkg.conf
sed -i 's/COMPRESSZST=.*/COMPRESSZST=(zstd -c -z -q --threads='"$nc"' -)/g' /etc/makepkg.conf