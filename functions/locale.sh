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

source "${CURRENT_DIR}/../install.conf" &>/dev/null
if [ -z "$TIMEZONE" ] || [ -z "$LOCALE" ]; then
  source "${CURRENT_DIR}/../dialogs/menu.sh"
  menuFlow setLocaleMenu setTimeZoneMenu
  if [ ! "$?" = "0" ]; then
    exit 1
  else
    CURRENT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    source "${CURRENT_DIR}/../install.conf"
  fi
fi
echo -ne "
--------------------------------------------------------------------
                      Changing Locale to ${LOCALE}
                 Changing Timezone to ${TIMEZONE}
--------------------------------------------------------------------
"
echo "LANG=${LOCALE}.UTF-8" | sudo tee /etc/locale.conf > /dev/null
echo "LC_COLLATE=C" | sudo tee -a /etc/locale.conf > /dev/null
sudo sed -i '/#'$LOCALE'.UTF-8/s/^#//g' /etc/locale.gen
sudo timedatectl set-ntp 1
sudo systemctl enable systemd-timesyncd.service
if [ -f "/usr/share/zoneinfo/${TIMEZONE}" ]; then
  sudo ln -sf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
fi
sudo hwclock --systohc --utc
sudo locale-gen