#!/usr/bin/env bash
#--------------------------------------------------------------------
#   █████╗ ██████╗  ██████╗██╗  ██╗██████╗  █████╗ ██╗   ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔══██╗██║   ██║██╔════╝
#  ███████║██████╔╝██║     ███████║██║  ██║███████║██║   ██║█████╗  
#  ██╔══██║██╔══██╗██║     ██╔══██║██║  ██║██╔══██║╚██╗ ██╔╝██╔══╝  
#  ██║  ██║██║  ██║╚██████╗██║  ██║██████╔╝██║  ██║ ╚████╔╝ ███████╗
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚══════╝
#--------------------------------------------------------------------

echo -e "\nFINAL SETUP AND CONFIGURATION"

# ------------------------------------------------------------------------


echo "-------------------------------------------------"
echo "       Setup Language to US and set locale       "
echo "-------------------------------------------------"
timedatectl --no-ask-password set-timezone Europe/Berlin
timedatectl --no-ask-password set-ntp 1
localectl --no-ask-password set-locale LANG="en_US.UTF-8" LC_COLLATE="C" LC_TIME="en_US.UTF-8"


echo -e "\nEnabling Login Display Manager"

sudo systemctl enable sddm.service

echo -e "\nEnabling ckb-next Daemon"
sudo systemctl enable ckb-next-daemon.service

echo -e "\nSetup SDDM Theme"

sudo cat <<EOF > /etc/sddm.conf
[Theme]
Current=breeze
EOF

sudo cat <<EOF >> /usr/share/sddm/scripts/Xsetup
xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto
/home/dave10/bin/xrandr_display
EOF

source "$HOME/ArchDave/setconsole.sh"

# ------------------------------------------------------------------------

echo -e "\nEnabling the cups service daemon so we can print"

systemctl enable cups.service
sudo ntpd -qg
sudo systemctl enable ntpd.service
sudo systemctl disable dhcpcd.service
sudo systemctl stop dhcpcd.service
sudo systemctl enable NetworkManager.service
echo "
###############################################################################
# Cleaning
###############################################################################
"
# Remove no password sudo rights
sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
# Add sudo rights
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

# Replace in the same state
cd $pwd
echo "
###############################################################################
# Done - Please Eject Install Media and Reboot
###############################################################################
"
