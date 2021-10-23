#!/bin/bash

for state in $(cat /sys/bus/pci/devices/0000\:01\:00.*/power/runtime_status)
do
	if [ "$state" != "suspended" ]; then
		indicator="#00B500"
	fi
done

printf '{"full_text":"o", "color":"%s"}\n' $indicator
