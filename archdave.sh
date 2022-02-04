#!/bin/bash
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
BASENAME="$( basename $SCRIPT_DIR)"

cleanLog() {
  if [ ! -f "$1" ]; then
    return
  fi
  sed -i "/\[97m/d" "$1" 
  cat "$1" | $SCRIPT_DIR/functions/filter.sh | tee "$1" &> /dev/null
  sed -i '/^\s*$/d' "$1"
}

script -qec "bash $SCRIPT_DIR/0-preinstall.sh" -O $SCRIPT_DIR/0-preinstall.log
if [ ! "$?" = "0" ]; then
  cleanLog $SCRIPT_DIR/0-preinstall.log
  exit
fi
cleanLog $SCRIPT_DIR/0-preinstall.log
script -qec "arch-chroot /mnt /root/$BASENAME/1-setup.sh" -O $SCRIPT_DIR/1-setup.log
if [ ! "$?" = "0" ]; then
  cleanLog $SCRIPT_DIR/1-setup.log
  exit
fi
cleanLog $SCRIPT_DIR/1-setup.log
source /mnt/root/$BASENAME/install.conf
script -qec "arch-chroot /mnt /usr/bin/runuser -u $USERNAME -- /home/$USERNAME/$BASENAME/2-user.sh" -O $SCRIPT_DIR/2-user.log
cleanLog $SCRIPT_DIR/2-user.log
script -qec "arch-chroot /mnt /root/$BASENAME/3-post-setup.sh" -O $SCRIPT_DIR/3-post-setup.log
cleanLog $SCRIPT_DIR/3-post-setup.log
cp $SCRIPT_DIR/*.log /mnt/home/$USERNAME/$BASENAME/
bash $SCRIPT_DIR/functions/exit.sh 0