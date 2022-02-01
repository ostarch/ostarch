#!/bin/bash
[ "$(id -u)" = "0" ] || exec sudo "$0" "$@"
CURRENT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

THEME_DIR="/boot/grub/themes"
THEME_NAME=Stylish

[[ -d ${THEME_DIR}/${THEME_NAME} ]] && rm -rf ${THEME_DIR}/${THEME_NAME}
mkdir -p "${THEME_DIR}/${THEME_NAME}"

cp -r ${CURRENT_DIR}/${THEME_NAME} ${THEME_DIR}

grep "GRUB_THEME=" /etc/default/grub 2>&1 >/dev/null && sed -i '/GRUB_THEME=/d' /etc/default/grub

echo "GRUB_THEME=\"${THEME_DIR}/${THEME_NAME}/theme.txt\"" >> /etc/default/grub