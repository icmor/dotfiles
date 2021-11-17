#!/bin/bash

rules_file="/etc/udev/rules.d/80-nvidia-pm.rules"

if [ "$EUID" -ne 0 ]; then
    echo "Root permission is needed to run this script"
    exit 1
fi

if [ ! -f "$rules_file" ]; then
    echo "File not found"
    exit 1
fi

if [[ "$(grep "^[^#].*0x040300.*$" "$rules_file")" ]]; then
    sed '/.*040300.*/s/^/# /' -i "$rules_file"
    udevadm control --reload-rules
    udevadm trigger
    echo "GPU audio ON"
elif  [[ "$(grep "^#.*0x040300.*$" "$rules_file")" ]]; then
    sed '/.*040300.*/s/^# //' -i "$rules_file"
    udevadm control --reload-rules
    udevadm trigger
    echo "GPU audio OFF"
else
    echo "Syntax not recognized"
fi
