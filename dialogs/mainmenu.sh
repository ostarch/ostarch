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
BASENAME="$( basename $CURRENT_DIR)"

for f in $(find "${CURRENT_DIR}/partitioning/" -type f); do source $f; done


menu() {
	$@
	exitcode="$?"
	if [ "$exitcode" = "0" ]; then
    menu $1
		exitcode="$?"
	fi
	return "$exitcode"
}

mainmenu() {
	options=()
	options+=("Disk Partitions" "")
	options+=("Select Partitions and Install" "")
	sel=$(whiptail --backtitle "$BASENAME" --title "Main Menu" --menu "" --cancel-button "Exit" 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3)
	if [ ! "$?" = "0" ]; then
		return 1
	fi
	case ${sel} in
		"Disk Partitions")
			menu partitionDiskMenu
			exitcode="$?"
		;;
		"Select Partitions and Install")
			menu selectPartitionMenu
			exitcode="$?"
		;;
	esac
	echo $exitcode
	if [ "$exitcode" = "2" ]; then
		return 1
	fi
}

menu mainmenu