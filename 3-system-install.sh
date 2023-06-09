#!/usr/bin/env bash
echo "*******************************************************"
echo "* 3                                                   *"
echo "*                   System-Install                    *"
echo "*                                                     *"
echo "*******************************************************"

# Skip Pacstrap (Base Install), if Done Earlier:
    set -e
    if [ "$part" -eq 1 ] && [ "$pa" -eq 1 ] then
        echo "Cond 1"
    elif [ "$part" -eq 1 ] && [ "$pa" -eq 2 ] then
        echo "Cond 2"
    fi