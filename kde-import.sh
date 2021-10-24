#!/bin/bash

export PATH=$PATH:~/.local/bin
pip install konsave
konsave -i $HOME/ArchDave/arc-kde.knsv
sleep 1
konsave -a arc-kde
