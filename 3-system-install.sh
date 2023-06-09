#!/usr/bin/env bash
echo "*******************************************************"
echo "* 3                                                   *"
echo "*                   System-Install                    *"
echo "*                                                     *"
echo "*******************************************************"

# Skip Pacstrap (Base Install), if Done Earlier:
    set -e
    if [ $part -eq 1 ]; then
        if [ $pa -eq 1 ]; then
            echo "Cond 1"
        fi
    fi
    set -e
    if [ $part -eq 1 ]; then
        if [ $pa -eq 2 ]; then
            echo "Cond 1"
        fi
    fi
    echo @Crossed
