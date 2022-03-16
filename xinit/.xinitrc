#!/bin/sh

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

export PATH="$PATH:$HOME/.local/bin"
export XAUTHORITY=~/.Xauthority
export NO_AT_BRIDGE=1
export MOZ_USE_XINPUT2=1

xset -dpms
xset s off
xrandr --rate 60 --dpi 96

exec i3
