#!/bin/bash

if [ "$(pamixer --get-mute)" = "false" ]; then
    icon="🔈"
else
    icon="🔇"
fi

echo $icon $(pamixer --get-volume)

if [ -n "$button" ]; then
	pavucontrol > /dev/null &
fi
