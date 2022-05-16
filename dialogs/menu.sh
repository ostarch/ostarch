#!/bin/bash
CURRENT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
for f in $(find "${CURRENT_DIR}/" -type f ! -name "mainmenu.sh" ! -name "menu.sh"); do source $f; done

menu() {
	$@
	exitcode="$?"
	if [ "$exitcode" = "0" ]; then
    menu $@
		exitcode="$?"
	fi
	return "$exitcode"
}

menuFlow() {
	i=1
	while [ "$i" -le "$#" ]; do
		eval "\${$i}"
		if [ "$?" = "0" ]; then
		  if [ "$i" -eq "$#" ]; then
		    return 0
		  fi
			i=$((i + 1))
		elif [ "$?" = "2" ]; then
			return 0
		else
			if [ "$i" -eq "1" ]; then
				return 1
			fi
			i=$((i - 1))
		fi
	done
}