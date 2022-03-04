#!/usr/bin/env bash
#--------------------------------------------------------------------
#   █████╗ ██████╗  ██████╗██╗  ██╗██████╗  █████╗ ██╗   ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔══██╗██║   ██║██╔════╝
#  ███████║██████╔╝██║     ███████║██║  ██║███████║██║   ██║█████╗  
#  ██╔══██║██╔══██╗██║     ██╔══██║██║  ██║██╔══██║╚██╗ ██╔╝██╔══╝  
#  ██║  ██║██║  ██║╚██████╗██║  ██║██████╔╝██║  ██║ ╚████╔╝ ███████╗
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚══════╝
#--------------------------------------------------------------------
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
BASENAME="$( basename $SCRIPT_DIR)"

$SCRIPT_DIR/functions/install/microcode.sh
$SCRIPT_DIR/functions/install/graphics-drivers.sh

echo -ne "
--------------------------------------------------------------------
                       Installing Base System  
--------------------------------------------------------------------
"
$SCRIPT_DIR/functions/install/install-packages.sh pacman || exit 1

echo -ne "
--------------------------------------------------------------------
                   Installing Desktop Environment  
--------------------------------------------------------------------
"
source $SCRIPT_DIR/install.conf
if [ -f "$SCRIPT_DIR/packages/desktop-environments/$DESKTOP_ENV.txt" ]; then
  $SCRIPT_DIR/functions/install/install-packages.sh desktop-environments/$DESKTOP_ENV || exit 1
fi

echo -ne "
--------------------------------------------------------------------
                      Installing Gaming Drivers
--------------------------------------------------------------------
"
$SCRIPT_DIR/functions/install/install-packages.sh pacman-gaming

echo -ne "
--------------------------------------------------------------------
                     System ready for 3-user.sh
--------------------------------------------------------------------
"