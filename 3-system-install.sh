#!/usr/bin/env bash
echo "*******************************************************"
echo "* 3                                                   *"
echo "*                   System-Install                    *"
echo "*                                                     *"
echo "*******************************************************"

# Skip Pacstrap (Base Install), if Done Earlier:
    set -e
    if [[ $part -eq 1 ]]; then
        if [[ $pa -eq 1 ]]; then
            pacman -Sy git
        fi
    fi
    set -e
    if [[ $part -eq 1 ]]; then
        if [[ $pa -eq 2 ]]; then
            pacman -Sy neovim
        fi
    fi
    echo @Crossed
