#!/usr/bin/env bash
#--------------------------------------------------------------------
#   █████╗ ██████╗  ██████╗██╗  ██╗██████╗  █████╗ ██╗   ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔══██╗██║   ██║██╔════╝
#  ███████║██████╔╝██║     ███████║██║  ██║███████║██║   ██║█████╗  
#  ██╔══██║██╔══██╗██║     ██╔══██║██║  ██║██╔══██║╚██╗ ██╔╝██╔══╝  
#  ██║  ██║██║  ██║╚██████╗██║  ██║██████╔╝██║  ██║ ╚████╔╝ ███████╗
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚══════╝
#--------------------------------------------------------------------
[ "$(id -u)" = "0" ] || exec sudo "$0" "$@"


sed -i 's/HibernateDelaySec=.*/HibernateDelaySec=30min/' /etc/systemd/sleep.conf
sed -i 's/#HibernateDelaySec=/HibernateDelaySec=/' /etc/systemd/sleep.conf

sed -i 's/HandleLidSwitch=.*/HandleLidSwitch=suspend-then-hibernate/' /etc/systemd/logind.conf
sed -i 's/#HandleLidSwitch=/HandleLidSwitch=/' /etc/systemd/logind.conf