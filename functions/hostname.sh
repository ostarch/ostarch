#!/usr/bin/env bash
#--------------------------------------------------------------------
#   ██████╗ ███████╗████████╗     █████╗ ██████╗  ██████╗██╗  ██╗
#  ██╔═══██╗██╔════╝╚══██╔══╝    ██╔══██╗██╔══██╗██╔════╝██║  ██║
#  ██║   ██║███████╗   ██║       ███████║██████╔╝██║     ███████║
#  ██║   ██║╚════██║   ██║       ██╔══██║██╔══██╗██║     ██╔══██║
#  ╚██████╔╝███████║   ██║       ██║  ██║██║  ██║╚██████╗██║  ██║
#   ╚═════╝ ╚══════╝   ╚═╝       ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝
#--------------------------------------------------------------------
CURRENT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

unset HOSTNAME
source "${CURRENT_DIR}/../install.conf" &>/dev/null
if [ -z "$HOSTNAME" ]; then
  source "${CURRENT_DIR}/../dialogs/menu.sh"
  menuFlow setHostnameMenu
  if [ ! "$?" = "0" ]; then
    exit 1
  else
    CURRENT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    source "${CURRENT_DIR}/../install.conf"
  fi
fi
echo -ne "
--------------------------------------------------------------------
                   Setting Hostname to $HOSTNAME
--------------------------------------------------------------------
"
echo "$HOSTNAME" | sudo tee /etc/hostname > /dev/null