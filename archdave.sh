#!/bin/bash
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
BASENAME="$( basename $SCRIPT_DIR)"

cleanLog() {
  cat "$1" | $SCRIPT_DIR/functions/filter.sh | tee "$1"
  sed -i "/\r/d" "$1"
}

pacman -Sy --noconfirm --needed expect
unbuffer bash $SCRIPT_DIR/0-preinstall.sh || exit 0 | tee $SCRIPT_DIR/0-preinstall.log
unbuffer arch-chroot /mnt /root/$BASENAME/1-setup.sh || exit 0 | tee $SCRIPT_DIR/1-setup.log
source /mnt/root/$BASENAME/install.conf
unbuffer arch-chroot /mnt /usr/bin/runuser -u $USERNAME -- /home/$USERNAME/$BASENAME/2-user.sh | tee $SCRIPT_DIR/2-user.log
unbuffer arch-chroot /mnt /root/$BASENAME/3-post-setup.sh | tee $SCRIPT_DIR/3-post-setup.log
bash $SCRIPT_DIR/functions/exit.sh 0

cleanLog $SCRIPT_DIR/0-preinstall.log
cleanLog $SCRIPT_DIR/1-setup.log
cleanLog $SCRIPT_DIR/2-user.log
cleanLog $SCRIPT_DIR/3-post-setup.log