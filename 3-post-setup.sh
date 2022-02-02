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
BASENAME="$( basename $SCRIPT_DIR)"

source $SCRIPT_DIR/install.conf

echo -ne "
--------------------------------------------------------------------
                    GRUB Bootloader Installation
--------------------------------------------------------------------
"
errors=0
installGrub() {
  if [[ ! -d "/sys/firmware/efi" ]]; then
      grub-install --boot-directory=/boot ${DISK}
  else
      grub-install --efi-directory=/boot ${DISK}
  fi
}
until installGrub
do
  if [[ $errors -ge 3 ]]; then
    echo "Grub installation failed"
    exit 1
  fi
  echo "Grub installation failed, retrying..."
  sleep 3
  errors=$((errors+1))
done

$SCRIPT_DIR/functions/grub.sh

echo -ne "
--------------------------------------------------------------------
                   Enabling Login Display Manager
--------------------------------------------------------------------
"
systemctl enable sddm.service

echo -ne "
--------------------------------------------------------------------
                      Enabling ckb-next Daemon
--------------------------------------------------------------------
"
systemctl enable ckb-next-daemon.service

echo -ne "
--------------------------------------------------------------------
                        Setting up SDDM Theme
--------------------------------------------------------------------
"
cat <<EOF > /etc/sddm.conf
[Theme]
Current=breeze
EOF

cat <<EOF >> /usr/share/sddm/scripts/Xsetup
/home/$USERNAME/bin/xrandr_display
EOF

echo -ne "
--------------------------------------------------------------------
                     Enabling Essential Services
--------------------------------------------------------------------
"

systemctl enable cups.service
systemctl disable dhcpcd.service
systemctl stop dhcpcd.service
systemctl enable NetworkManager.service
systemctl enable bluetooth.service
if ! systemd-detect-virt &>/dev/null; then
  systemctl enable libvirtd.service
fi
echo -ne "
--------------------------------------------------------------------
                              Cleaning 
--------------------------------------------------------------------
"
# Remove no password sudo rights
sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
# Add sudo rights
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

rm -r /root/"$BASENAME"

# Replace in the same state
cd $pwd
echo -ne "
--------------------------------------------------------------------
   █████╗ ██████╗  ██████╗██╗  ██╗██████╗  █████╗ ██╗   ██╗███████╗
  ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔══██╗██║   ██║██╔════
  ███████║██████╔╝██║     ███████║██║  ██║███████║██║   ██║█████╗  
  ██╔══██║██╔══██╗██║     ██╔══██║██║  ██║██╔══██║╚██╗ ██╔╝██╔══╝ 
  ██║  ██║██║  ██║╚██████╗██║  ██║██████╔╝██║  ██║ ╚████╔╝ ███████╗
  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚══════╝
--------------------------------------------------------------------
            Done - Please Eject Install Media and Reboot
--------------------------------------------------------------------
"