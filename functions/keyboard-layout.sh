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

source "${CURRENT_DIR}/../install.conf" &>/dev/null
if [ -z "$KEYMAP" ]; then
  source "${CURRENT_DIR}/../dialogs/menu.sh"
  menuFlow setKeyboardLayoutMenu
  if [ ! "$?" = "0" ]; then
    exit 1
  else
    CURRENT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    source "${CURRENT_DIR}/../install.conf"
  fi
fi
echo -ne "
--------------------------------------------------------------------
                   Changing Keyboard Layout to ${KEYMAP}
--------------------------------------------------------------------
"
sudo localectl set-keymap "${KEYMAP}"