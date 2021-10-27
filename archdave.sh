#!/bin/bash

    bash 0-preinstall.sh
    arch-chroot /mnt /root/ArchDave/1-setup.sh
    source /mnt/root/ArchDave/install.conf
    arch-chroot /mnt /usr/bin/runuser -u $username -- /home/$username/ArchDave/2-user.sh
    arch-chroot /mnt /root/ArchDave/3-post-setup.sh