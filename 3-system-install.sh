#!/usr/bin/env bash
echo "*******************************************************"
echo "* 3                                                   *"
echo "*                   System-Install                    *"
echo "*                                                     *"
echo "*******************************************************"

part=1
pa=1


# Skip Pacstrap (Base Install), if Done Earlier:
    set -e
    if [[ $part -eq 1 ]] && [[ $pa -eq 1 ]]; then
        echo "Condition 1"
    fi
    set -e
    if [[ $part -eq 1 ]] && [[ $pa -eq 2 ]]; then
        echo "Condition 2"
    fi