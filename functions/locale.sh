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

if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

source "${CURRENT_DIR}/../install.conf"
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
-------------------------------------------------------------------------
                     Changing Locale to ${LOCALE}
                 Changing Timezone to ${TIMEZONE}
-------------------------------------------------------------------------
"
echo "LANG=${LOCALE}.UTF-8" > /etc/locale.conf
echo "LC_COLLATE=C" >> /etc/locale.conf
sed -i '/#'$LOCALE'.UTF-8/s/^#//g' /etc/locale.gen
timedatectl set-ntp 1
if [ -f "/usr/share/zoneinfo/${TIMEZONE}" ]; then
  ln -sf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
fi
hwclock --systohc
locale-gen