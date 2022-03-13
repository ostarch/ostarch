#!/bin/bash
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
BASENAME="$( basename $SCRIPT_DIR)"

cleanLog() {
  if [ ! -f "$1" ]; then
    return
  fi
  sed -i '/[0-9]%/d' "$1"
  sed -i '/\[97m/d' "$1"
  cat "$1" | $SCRIPT_DIR/functions/filter.sh | tee "$1" &> /dev/null
  sed -i '/^\s*$/d' "$1"
}

runAndLog() {
  local logfile="$SCRIPT_DIR/logs/$(basename "$1" .sh).log"
  script -qec "$1" -O "$logfile"
  local errorCode="$?"
  cleanLog "$logfile"
  return $errorCode
}

mkdir "$SCRIPT_DIR/logs"
runAndLog "bash $SCRIPT_DIR/0-preinstall.sh" || exit
runAndLog "arch-chroot /mnt /root/$BASENAME/1-setup.sh" || exit
runAndLog "arch-chroot /mnt /root/$BASENAME/2-install.sh" || exit
source /mnt/root/$BASENAME/install.conf
runAndLog "arch-chroot /mnt /usr/bin/runuser -u $USERNAME -- /home/$USERNAME/$BASENAME/3-user.sh" || exit
runAndLog "arch-chroot /mnt /root/$BASENAME/4-post-setup.sh" || exit
cp -r $SCRIPT_DIR/logs /mnt/home/$USERNAME/$BASENAME/
cp $SCRIPT_DIR/install.conf /mnt/home/$USERNAME/$BASENAME/logs/
rm /mnt/home/$USERNAME/$BASENAME/install.conf &>/dev/null
bash $SCRIPT_DIR/functions/exit.sh 0