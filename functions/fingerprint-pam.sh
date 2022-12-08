#!/bin/bash
#--------------------------------------------------------------------
#   █████╗ ██████╗  ██████╗██╗  ██╗██████╗  █████╗ ██╗   ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔══██╗██║   ██║██╔════╝
#  ███████║██████╔╝██║     ███████║██║  ██║███████║██║   ██║█████╗  
#  ██╔══██║██╔══██╗██║     ██╔══██║██║  ██║██╔══██║╚██╗ ██╔╝██╔══╝  
#  ██║  ██║██║  ██║╚██████╗██║  ██║██████╔╝██║  ██║ ╚████╔╝ ███████╗
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚══════╝
#--------------------------------------------------------------------
[ "$(id -u)" = "0" ] || exec sudo "$0" "$@"

try_first_pass="auth\t\tsufficient\tpam_unix.so try_first_pass likeauth nullok"
sufficient_fprintd="auth\t\tsufficient\tpam_fprintd.so"

if type "fprintd-list" &> /dev/null && fprintd-list root 2>/dev/null | grep -vq 'No devices available'; then
  sed -i.old "1s;^;$sufficient_fprintd\n;" /etc/pam.d/{system-local-login,login,su,sudo,lightdm}
fi
systemctl disable fingerprint-pam-post-startup.service &>/dev/null
rm /etc/systemd/system/fingerprint-pam-post-startup.service &>/dev/null
