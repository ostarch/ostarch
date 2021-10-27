#!/bin/bash

if [ $(whoami) = "root"  ]; then
  echo "Don't run this as root!"
  exit
fi

konsave -s arc-kde
konsave -e arc-kde