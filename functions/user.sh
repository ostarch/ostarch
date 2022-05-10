#!/usr/bin/env bash
#--------------------------------------------------------------------
#   █████╗ ██████╗  ██████╗██╗  ██╗██████╗  █████╗ ██╗   ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔══██╗██║   ██║██╔════╝
#  ███████║██████╔╝██║     ███████║██║  ██║███████║██║   ██║█████╗  
#  ██╔══██║██╔══██╗██║     ██╔══██║██║  ██║██╔══██║╚██╗ ██╔╝██╔══╝  
#  ██║  ██║██║  ██║╚██████╗██║  ██║██████╔╝██║  ██║ ╚████╔╝ ███████╗
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚══════╝
#--------------------------------------------------------------------
CURRENT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

unset USERNAME
source "${CURRENT_DIR}/../install.conf" &>/dev/null
if [ ! -z "$USERNAME" ] && id "$USERNAME" &>/dev/null; then
  sed -i '/^PASSWORD=/d' "${CURRENT_DIR}/../install.conf" &>/dev/null
  exit
fi
if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
  source "${CURRENT_DIR}/../dialogs/menu.sh"
  menuFlow addUserMenu setUserPasswordMenu
  if [ ! "$?" = "0" ]; then
    exit 1
  else
    CURRENT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    source "${CURRENT_DIR}/../install.conf"
  fi
fi
echo -ne "
--------------------------------------------------------------------
                         Adding User $USERNAME
--------------------------------------------------------------------
"
sudo useradd -m -N -G wheel -s /bin/bash "$USERNAME"
sudo usermod -p "$PASSWORD" "$USERNAME"
if [ "$?" = "0" ]; then
  sed -i '/^PASSWORD=/d' "${CURRENT_DIR}/../install.conf"
  unset PASSWORD
fi
if grep -qE "^libvirt:" /etc/group; then
  echo "Adding user $USERNAME to the libvirt group"
  sudo usermod -aG libvirt "$USERNAME"
fi
sudo grpck