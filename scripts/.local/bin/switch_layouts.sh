#!/bin/bash

layout="$(setxkbmap -query | awk '/layout/ {print $2}')"

if [ "$layout" != "us" ]; then
    setxkbmap -layout "us"
else
    setxkbmap -layout "latam"
fi
