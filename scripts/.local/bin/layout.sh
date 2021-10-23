#!/bin/bash

layout="$(setxkbmap -query | awk '/layout/ {print $2}')"
if [ "$layout" == "latam" ]; then
    echo "Ñ"
fi
