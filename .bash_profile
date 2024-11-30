[[ -f ~/.bashrc ]] && . ~/.bashrc

export PATH=${PATH}:${HOME}/.local/bin
export NO_AT_BRIDGE=1	# supress gtk accessibility warnings

# video
export LIBVA_DRIVER_NAME=iHD
export __GL_GSYNC_ALLOWED=0
export __GL_VRR_ALLOWED=0
export WLR_RENDERER=vulkan

# gpu
export __GLX_VENDOR_LIBRARY_NAME=mesa
export GAMEMODERUNEXEC="env __NV_PRIME_RENDER_OFFLOAD=1 \
__GLX_VENDOR_LIBRARY_NAME=nvidia __VK_LAYER_NV_optimus=NVIDIA_only"

# theming
export QT_STYLE_OVERRIDE=adwaita-dark
export GTK_THEME=Adwaita:dark

# wayland
export SDL_VIDEODRIVER=wayland,x11
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_DESKTOP=sway
export XDG_SESSION_TYPE=wayland
export _JAVA_AWT_WM_NONREPARENTING=1

# misc
export GPROFNG_SYSCONFDIR="/etc/" # fix binutils packaging error
export EDITOR="vim"
export ERROR_FLAGS="-Wall -Wextra -Wconversion -Wundef -Wformat=2 \
-Wformat-truncation -Wdouble-promotion -Wshadow -fno-common"
export SANITIZER_FLAGS="-fsanitize=address -fsanitize=undefined -fsanitize=leak"

TTY="$(tty)"
if [ "$TTY" = "/dev/tty1" ]; then
    # intel
    export __EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/50_mesa.json
    exec sway --unsupported-gpu
elif [ "$TTY" = "/dev/tty2" ]; then
    # nvidia
    WLR_DRM_DEVICES=/dev/dri/card0 exec sway --unsupported-gpu
fi
