[[ $- != *i* ]] && return

# shellopts
[[ $DISPLAY ]] && shopt -s checkwinsize
shopt -s histappend
set -b

# variables
HISTCONTROL=erasedups
HISTSIZE=-1
HISTFILESIZE=-1
PROMPT_DIRTRIM=2
[[ -f ~/.env ]] && source ~/.env

# XDG
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

export CARGO_HOME="$XDG_DATA_HOME"/cargo
export CUDA_CACHE_PATH="$XDG_CACHE_HOME"/nv
export DOTNET_CLI_HOME="$XDG_DATA_HOME"/dotnet
export GHCUP_USE_XDG_DIRS="true"
export GOPATH="$XDG_DATA_HOME"/go
export HISTFILE="$XDG_STATE_HOME"/bash/history
# export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java
export LESSHISTFILE="$XDG_STATE_HOME"/less/history
export MYPY_CACHE_DIR="$XDG_CACHE_HOME/mypy"
export NUGET_PACKAGES="$XDG_CACHE_HOME"/NuGetPackages
export PARALLEL_HOME="$XDG_CONFIG_HOME"/parallel
export PYTHONPYCACHEPREFIX="$XDG_CACHE_HOME"/pycache
export TEXMFVAR="$XDG_CACHE_HOME"/texlive/texmf-var
export WINEPREFIX="$XDG_DATA_HOME"/wine
export WORKON_HOME="$XDG_DATA_HOME"/virtualenvs
export XAUTHORITY="$XDG_RUNTIME_DIR"/Xauthority

alias mitmproxy="mitmproxy --set confdir=$XDG_CONFIG_HOME/mitmproxy"
alias mitmweb="mitmweb --set confdir=$XDG_CONFIG_HOME/mitmproxy"

case "$TERM" in
    *color*|foot)
	PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
	;;
    *)
	PS1="[\u@\h]:\w\$ "
	;;
esac

# aliases
alias ls='ls --color=auto'
alias dir='dir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ll='ls -Alh'
alias l='ls -CAF'

alias gcd="cd \$(git rev-parse --show-toplevel)"
alias ed="emacs -nw"
alias open="xdg-open"
alias trash="gio trash"
alias wlan="iwctl station wlan0"

alias exton="swaymsg output HDMI-A-2 enable \
&& pactl set-default-sink alsa_output.pci-0000_03_00.1.hdmi-stereo-extra3"
alias extoff="swaymsg output HDMI-A-2 disable"
alias nvidia_reset="sudo rmmod nvidia_drm && sudo modprobe nvidia_drm"
alias caffeine="systemd-inhibit sleep inf"
alias vmware_start="pkexec sh -c 'systemctl start vmware-networks \
&& modprobe -a vmw_vmci vmmon' && vmware 1>&2 2>&- &"
alias vmware_stop="pkexec sh -c 'systemctl stop vmware-networks \
&& rmmod vmw_vsock_vmci_transport vmw_vmci vmmon'"

# functions
function destroy {
    for pid in $(psgrep "$1" | tr -s ' ' | cut -d' ' -f2); do kill -9 $pid; done
}

function docker_latest {
	sudo docker ps | head -2 | tail -1 | cut -d' ' -f 1
}

function docker_connect {
	sudo docker exec -it "$(docker_latest)" bash
}

function dropbox_ignore {
    attr -s com.dropbox.ignored -V 1 "$1"
}

function pdf_grayscale {
    gs -sDEVICE=pdfwrite -sProcessColorModel=DeviceGray \
       -sColorConversionStrategy=Gray -dOverrideICC -o "$2" -f "$1"
}

function psgrep  {
    ps aux | grep --color=auto -i "$1" | grep -v grep
}

# emacs
if [[ "$INSIDE_EMACS" == *"comint"* ]]; then
    unset COLUMNS
    export PAGER=cat
    export TERM=dumb-color
elif [[ "$INSIDE_EMACS" = 'vterm' ]]; then
    function vterm_printf(){
         printf "\e]%s\e\\" "$1"
    }
    function vterm_prompt_end(){
	vterm_printf "51;A$(whoami)@$(cat /etc/hostname):$(pwd)"
    }
    PS1=$PS1'\[$(vterm_prompt_end)\]'
elif [[ -n "$EMACS_BASH_COMPLETE" ]]; then
    unset HISTFILE
fi
