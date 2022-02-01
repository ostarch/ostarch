#!/bin/bash
#--------------------------------------------------------------------
#   █████╗ ██████╗  ██████╗██╗  ██╗██████╗  █████╗ ██╗   ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔══██╗██║   ██║██╔════╝
#  ███████║██████╔╝██║     ███████║██║  ██║███████║██║   ██║█████╗  
#  ██╔══██║██╔══██╗██║     ██╔══██║██║  ██║██╔══██║╚██╗ ██╔╝██╔══╝  
#  ██║  ██║██║  ██║╚██████╗██║  ██║██████╔╝██║  ██║ ╚████╔╝ ███████╗
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚══════╝
#--------------------------------------------------------------------
CONFIG_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

setKeyboardLayoutMenu() {
  options=()
  keymaps=$(localectl list-keymaps)
	for keymap in $keymaps; do
	 options+=("$keymap" "")
	done
  result=$(whiptail --backtitle "${TITLE}" --title "Set Keyboard Layout" --menu "" --cancel-button "Back" --default-item "us" 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3)
  if [ ! "$?" = "0" ]; then
    return 1
  fi
  sudo loadkeys "$result"
  echo "KEYMAP=$result" >> "${CONFIG_DIR}/../../install.conf"
}


# Not used
setKeyboardLayoutMenuXKB() {
  layouts=$(sed '/! layout/,/^$/!d' < /usr/share/X11/xkb/rules/evdev.lst)
  options=()
  while read -r line; do
    letters=$(echo "$line" | awk '{ print $1; }')
    description=$(echo "$line" | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}')
    if [[ "$letters" == "!" || "$letters" == "custom" ]]; then
      continue
    fi
    options+=("$letters" "$description")
  done < <(echo "$layouts")
  result=$(whiptail --backtitle "${TITLE}" --title "Set Keyboard Layout" --menu "" --cancel-button "Back" 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3)
  if [ "$?" = "0" ]; then
    echo $result
  fi
}