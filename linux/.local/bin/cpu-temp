#!/bin/bash

temp=$(cat /sys/class/thermal/thermal_zone4/temp)
temp=$(($temp / 1000))

if [ $temp -le 50 ]; then
	color="#66E1E3"
elif [ $temp -le 70 ]; then
	color="#FFC125"
else
	color="#FF0000"
fi

printf '{"full_text":"%s", "color":"%s"}\n' ${temp}°C $color
