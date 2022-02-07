#!/bin/bash
[ "$(id -u)" = "0" ] || exec sudo "$0" "$@"
CURRENT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

THEME_DIR="/boot/grub/themes"
THEME_NAME=Stylish
ICON="color"

[[ -d ${THEME_DIR}/${THEME_NAME} ]] && rm -rf ${THEME_DIR}/${THEME_NAME}
mkdir -p "${THEME_DIR}/${THEME_NAME}"

cp ${CURRENT_DIR}/${THEME_NAME}/*.* ${THEME_DIR}/${THEME_NAME}
cp -r ${CURRENT_DIR}/${THEME_NAME}/icons-${ICON} ${THEME_DIR}/${THEME_NAME}/icons

if grep -q "GRUB_GFXMODE=auto" /etc/default/grub || grep -q "GRUB_GFXMODE=\"auto\"" /etc/default/grub; then
  sed -i "s|.*GRUB_GFXMODE=.*|GRUB_GFXMODE=\"1920x1080,auto\"|" /etc/default/grub
fi

if grep -q "GRUB_THEME=" /etc/default/grub; then
  sed -i "s|.*GRUB_THEME=.*|GRUB_THEME=\"${THEME_DIR}/${THEME_NAME}/theme.txt\"|" /etc/default/grub
else
  echo "GRUB_THEME=\"${THEME_DIR}/${THEME_NAME}/theme.txt\"" >> /etc/default/grub
fi

if grep -qE "^GRUB_TERMINAL=console" /etc/default/grub || grep -qE "^GRUB_TERMINAL=\"console\"" /etc/default/grub; then
  sed -i "s|.*GRUB_TERMINAL=.*|#GRUB_TERMINAL=\"console\"|" /etc/default/grub
fi
if grep -qE "^GRUB_TERMINAL_OUTPUT=console" /etc/default/grub || grep -qE "^GRUB_TERMINAL_OUTPUT=\"console\"" /etc/default/grub; then
  sed -i "s|.*GRUB_TERMINAL_OUTPUT=.*|#GRUB_TERMINAL_OUTPUT=\"console\"|" /etc/default/grub
fi