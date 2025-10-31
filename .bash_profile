[[ -f ~/.bashrc ]] && . ~/.bashrc

HOSTNAME=$(hostnamectl hostname)
export PATH=${PATH}:${HOME}/.local/bin
export NO_AT_BRIDGE=1	# supress gtk accessibility warnings
export EDITOR="vim"

# theming
export QT_STYLE_OVERRIDE=adwaita-dark
export GTK_THEME=Adwaita:dark

# video
export WLR_RENDERER=vulkan
export MESA_VK_IGNORE_CONFORMANCE_WARNING=true
if [ $HOSTNAME = "turing" ]; then
    export LIBVA_DRIVER_NAME=i965
    export DXVK_FRAME_RATE=60
    ## optimus
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
elif [ $HOSTNAME = "turing" ]; then
    export LIBVA_DRIVER_NAME=radeonsi
fi

# wayland
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_DESKTOP=sway
export XDG_SESSION_TYPE=wayland
export _JAVA_AWT_WM_NONREPARENTING=1

# sway
if [ $HOSTNAME = "navi" ]; then
    [ "$(tty)" = "/dev/tty1" ] && exec sway
elif [ $HOSTNAME = "turing" ]; then
    if [ "$(tty)" = "/dev/tty1" ]; then
	exec sway --unsupported-gpu
    elif [ "$(tty)" = "/dev/tty2" ]; then
	export __EGL_VENDOR_LIBRARY_FILENAMES=$GLVND_NVIDIA
	WLR_DRM_DEVICES=/dev/dri/card0 exec sway --unsupported-gpu # nvidia
    fi
fi
