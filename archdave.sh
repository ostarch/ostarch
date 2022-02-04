#!/bin/bash
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
BASENAME="$( basename $SCRIPT_DIR)"

cleanLog() {
  if [ ! -f "$1" ]; then
    return
  fi
  cat "$1" | $SCRIPT_DIR/functions/filter.sh | tee "$1" &> /dev/null
  sed -i "/\r/d" "$1"
  sed -i '/^\s*$/d' "$1"
}

pacman -Sy --noconfirm --needed expect
script -qec "bash $SCRIPT_DIR/0-preinstall.sh" -O $SCRIPT_DIR/0-preinstall.log || ( cleanLog $SCRIPT_DIR/0-preinstall.log && exit 0 )
script -qec "arch-chroot /mnt /root/$BASENAME/1-setup.sh" -O $SCRIPT_DIR/1-setup.log || ( cleanLog $SCRIPT_DIR/1-setup.log && exit 0 )
source /mnt/root/$BASENAME/install.conf
script -qec "arch-chroot /mnt /usr/bin/runuser -u $USERNAME -- /home/$USERNAME/$BASENAME/2-user.sh" -O $SCRIPT_DIR/2-user.log
script -qec "arch-chroot /mnt /root/$BASENAME/3-post-setup.sh" -O $SCRIPT_DIR/3-post-setup.log
bash $SCRIPT_DIR/functions/exit.sh 0

cleanLog $SCRIPT_DIR/0-preinstall.log
cleanLog $SCRIPT_DIR/1-setup.log
cleanLog $SCRIPT_DIR/2-user.log
cleanLog $SCRIPT_DIR/3-post-setup.log