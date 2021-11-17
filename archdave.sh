#!/bin/bash
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
BASENAME="$( basename $SCRIPT_DIR)"

bash $SCRIPT_DIR/0-preinstall.sh || exit 0
arch-chroot /mnt /root/$BASENAME/1-setup.sh
source /mnt/root/$BASENAME/install.conf
arch-chroot /mnt /usr/bin/runuser -u $username -- /home/$username/$BASENAME/2-user.sh
arch-chroot /mnt /root/$BASENAME/3-post-setup.sh
bash $SCRIPT_DIR/functions/exit.sh 0