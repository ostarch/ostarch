#!/bin/bash
#--------------------------------------------------------------------
#   ██████╗ ███████╗████████╗     █████╗ ██████╗  ██████╗██╗  ██╗
#  ██╔═══██╗██╔════╝╚══██╔══╝    ██╔══██╗██╔══██╗██╔════╝██║  ██║
#  ██║   ██║███████╗   ██║       ███████║██████╔╝██║     ███████║
#  ██║   ██║╚════██║   ██║       ██╔══██║██╔══██╗██║     ██╔══██║
#  ╚██████╔╝███████║   ██║       ██║  ██║██║  ██║╚██████╗██║  ██║
#   ╚═════╝ ╚══════╝   ╚═╝       ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝
#--------------------------------------------------------------------
CONFIG_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

setLocaleMenu() {
	options=()
  locales=$(ls /usr/share/i18n/locales)
	for locale in $locales; do
	  options+=("$locale" "")
	done
  result=$(whiptail --backtitle "${TITLE}" --title "Set Locale" --menu "" --cancel-button "Back" --default-item "en_US" 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3)
  if [ ! "$?" = "0" ]; then
    return 1
  fi
  echo "LOCALE=$result" >> "${CONFIG_DIR}/../../install.conf"
}