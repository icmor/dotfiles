#!/bin/bash

action=$(echo -e 'logout\nsuspend\nshutdown\nreboot' | dmenu -i -p "Power Menu")

case "$action" in
    "logout") i3-msg exit
	      ;;
    "suspend") systemctl suspend
	       ;;
    "shutdown") systemctl poweroff
		;;
    "reboot") reboot
	      ;;
esac
