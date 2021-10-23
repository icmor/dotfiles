#!/bin/sh

# start some nice programs
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

export PATH="$PATH:$HOME/.local/bin"
export XAUTHORITY=~/.Xauthority
export ASPELL_CONF="home-dir $HOME/.config/aspell"
export MOZ_X11_EGL=1

xset -dpms
xset s off
xrandr -r 60

exec i3
