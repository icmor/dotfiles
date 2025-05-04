[[ -f ~/.bashrc ]] && . ~/.bashrc

export PATH=${PATH}:${HOME}/.local/bin
export NO_AT_BRIDGE=1	# supress gtk accessibility warnings
export DXVK_FRAME_RATE=60
export EDITOR="vim"

# video
export LIBVA_DRIVER_NAME=i965
export WLR_RENDERER=vulkan

# optimus
# https://bbs.archlinux.org/viewtopic.php?pid=2094847#p2094847
GLVND_INTEL="/usr/share/glvnd/egl_vendor.d/50_mesa.json"
GLVND_NVIDIA="/usr/share/glvnd/egl_vendor.d/10_nvidia.json"
export __EGL_VENDOR_LIBRARY_FILENAMES=$GLVND_INTEL
export __GLX_VENDOR_LIBRARY_NAME=mesa
export GAMEMODERUNEXEC="env \
       __EGL_VENDOR_LIBRARY_FILENAMES=$GLVND_NVIDIA
       __NV_PRIME_RENDER_OFFLOAD=1 \
       __GLX_VENDOR_LIBRARY_NAME=nvidia \
        __VK_LAYER_NV_optimus=NVIDIA_only"

# theming
export QT_STYLE_OVERRIDE=adwaita-dark
export GTK_THEME=Adwaita:dark

# wayland
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_DESKTOP=sway
export XDG_SESSION_TYPE=wayland
export _JAVA_AWT_WM_NONREPARENTING=1

TTY="$(tty)"
if [ "$TTY" = "/dev/tty1" ]; then
    exec sway --unsupported-gpu
elif [ "$TTY" = "/dev/tty2" ]; then
    export __EGL_VENDOR_LIBRARY_FILENAMES=$GLVND_NVIDIA
    WLR_DRM_DEVICES=/dev/dri/card0 exec sway --unsupported-gpu # nvidia
fi
