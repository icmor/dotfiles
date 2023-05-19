#!/bin/bash

if ! [[ "$(xdotool getactivewindow getwindowclassname)" == "Emacs" &&
	  "$(emacsclient -e "(windmove-$1)")" ]]; then
    i3-msg focus $1
fi
