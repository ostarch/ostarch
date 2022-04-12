#!/bin/bash
#--------------------------------------------------------------------
#   █████╗ ██████╗  ██████╗██╗  ██╗██████╗  █████╗ ██╗   ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔══██╗██║   ██║██╔════╝
#  ███████║██████╔╝██║     ███████║██║  ██║███████║██║   ██║█████╗  
#  ██╔══██║██╔══██╗██║     ██╔══██║██║  ██║██╔══██║╚██╗ ██╔╝██╔══╝  
#  ██║  ██║██║  ██║╚██████╗██║  ██║██████╔╝██║  ██║ ╚████╔╝ ███████╗
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚══════╝
#--------------------------------------------------------------------

if [ $(whoami) = "root"  ]; then
  echo "Don't run this as root!"
  exit
fi

export PATH=$PATH:~/.local/bin
if ! type konsave &> /dev/null; then
  pip install konsave
fi
konsave -r arc-kde
konsave -s arc-kde
sed -i '/^History Items/d' "$HOME/.config/konsave/profiles/arc-kde/configs/kdeglobals"
sed -i '/^LaunchCounts/d' "$HOME/.config/konsave/profiles/arc-kde/configs/plasmashellrc"
konsave -e arc-kde