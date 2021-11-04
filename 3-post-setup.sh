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

source "${SCRIPT_DIR}/install.conf"

echo "-------------------------------------------------"
echo "          FINAL SETUP AND CONFIGURATION          "
echo "-------------------------------------------------"

echo "--------------------------------------"
echo "-- GRUB Bootloader Installation     --"
echo "--------------------------------------"
if [[ ! -d "/sys/firmware/efi" ]]; then
    grub-install --boot-directory=/boot ${DISK}
else
    grub-install --efi-directory=/boot ${DISK}
fi

grub-mkconfig -o /boot/grub/grub.cfg

# ------------------------------------------------------------------------

echo -e "\nEnabling Login Display Manager"

systemctl enable sddm.service

echo -e "\nEnabling ckb-next Daemon"
systemctl enable ckb-next-daemon.service

echo -e "\nSetup SDDM Theme"
cat <<EOF > /etc/sddm.conf
[Theme]
Current=breeze
EOF

cat <<EOF >> /usr/share/sddm/scripts/Xsetup
/home/dave10/bin/xrandr_display
EOF

source "$SCRIPT_DIR/functions/setconsole.sh"

# ------------------------------------------------------------------------

echo -e "\nEnabling essential services"

systemctl enable cups.service
ntpd -qg
systemctl enable ntpd.service
systemctl disable dhcpcd.service
systemctl stop dhcpcd.service
systemctl enable NetworkManager.service
systemctl enable bluetooth
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
