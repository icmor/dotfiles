#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

export PATH=${PATH}:${HOME}/.local/bin
export LIBVA_DRIVER_NAME=iHD
export NO_AT_BRIDGE=1
export _JAVA_AWT_WM_NONREPARENTING=1
export MOZ_ENABLE_WAYLAND=1
export GTK_THEME=Adwaita:dark
export QT_STYLE_OVERRIDE=adwaita-dark
export QT_QPA_PLATFORM=wayland
export SDL_VIDEODRIVER=wayland
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_DESKTOP=sway

if [ -z "${DISPLAY}" ] && [ "$(tty)" = "/dev/tty1" ]; then
	exec sway --unsupported-gpu
fi
