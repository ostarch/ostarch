#!/usr/bin/env bash
echo "*******************************************************"
echo "* 3                                                   *"
echo "*                   System-Install                    *"
echo "*                                                     *"
echo "*******************************************************"

# Skip Pacstrap (Base Install), if Done Earlier:
    set -e
    if [[ $part -eq 1 ]] && [[ $pa -eq 1 ]]; then
        echo "Condition 1"
        echo $part
        echo $pa
    fi
    set -e
    if [[ $part -eq 1 ]] && [[ $pa -eq 2 ]]; then
        echo "Condition 2"
        echo $part
        echo $pa
    fi