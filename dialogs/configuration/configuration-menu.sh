#!/bin/bash
#--------------------------------------------------------------------
#   █████╗ ██████╗  ██████╗██╗  ██╗██████╗  █████╗ ██╗   ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔══██╗██║   ██║██╔════╝
#  ███████║██████╔╝██║     ███████║██║  ██║███████║██║   ██║█████╗  
#  ██╔══██║██╔══██╗██║     ██╔══██║██║  ██║██╔══██║╚██╗ ██╔╝██╔══╝  
#  ██║  ██║██║  ██║╚██████╗██║  ██║██████╔╝██║  ██║ ╚████╔╝ ███████╗
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚══════╝
#--------------------------------------------------------------------
CURRENT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

configurationMenu() {
  menuFlow setHostnameMenu setKeyboardLayoutMenu setLocaleMenu setTimeZoneMenu
  return "$?"
}

setHostnameMenu() {
  hostname=$(whiptail --backtitle "${TITLE}" --title "Set Computer Name" --inputbox "" 0 0 "archlinux" 3>&1 1>&2 2>&3)
  if [ ! "$?" = "0" ]; then
    return 1
  fi
  echo "HOSTNAME=$hostname" >> "${CURRENT_DIR}/../../install.conf"
}

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
  loadkeys "$result"
  echo "KEYMAP=$result" >> "${CURRENT_DIR}/../../install.conf"
}

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
  echo "LOCALE=$result" >> "${CURRENT_DIR}/../../install.conf"
}

setTimeZoneMenu() {
  localTimezone="$(curl -s --connect-timeout 2 --fail https://ipapi.co/timezone)"
  if [ -z "$timezone" ]; then
    localTimezone="Europe/Berlin"
  fi
  options=()
  timezones=$(timedatectl list-timezones)
  for timezone in $timezones; do
    options+=("$timezone" "")
  done
  result=$(whiptail --backtitle "${TITLE}" --title "Set Time Zone" --menu "" --cancel-button "Back" --default-item "$localTimezone" 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3)
  if [ ! "$?" = "0" ]; then
    return 1
  fi
  echo "TIMEZONE=$result" >> "${CURRENT_DIR}/../../install.conf"
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