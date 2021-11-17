#!/bin/bash

path="/sys/class/power_supply/BAT0"
echo $(echo "scale=1; $(cat ${path}/current_now)\
 * $(cat ${path}/voltage_now) / 10^12" | bc)

