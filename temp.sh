#!/usr/bin/env bash
echo "****************************************************************"
echo "* 2 ____     _____   _______                            _      *"
echo "*  / __ \   / ____| |__   __|     /\                   | |     *"
echo "* | |  | | | (___      | |       /  \     _ __    ___  | |__   *"
echo "*                                                              *" 
echo "*                                                              *"   # Delete It Later
echo "*  \____/  |_____/     |_|    /_/    \_\ |_|     \___| |_| |_| *"
echo "*                                                              *"
echo "****************************************************************"
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )" # Get the value of Present Directory
cp -R ${SCRIPT_DIR} /mnt/root/  