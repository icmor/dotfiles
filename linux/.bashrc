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
export EDITOR="vim"
export GCC_COLORS="error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01"
export MYPY_CACHE_DIR="${HOME}/.cache/mypy"
export PYTHONPYCACHEPREFIX="${HOME}/.cache/pycache"

case "$TERM" in
    *color*|alacritty)
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
alias open="xdg-open"
alias trash="gio trash"
alias wlan="iwctl station wlan0"

alias gsan="gcc -fsanitize=address -fsanitize=undefined"\
" -fno-sanitize-recover=all -fsanitize=float-divide-by-zero"\
" -fsanitize=float-cast-overflow -fno-sanitize=null -fno-sanitize=alignment"
alias prime_run='DRI_PRIME=pci-0000_01_00_0 __VK_LAYER_NV_optimus=NVIDIA_only"\
" __GLX_VENDOR_LIBRARY_NAME=nvidia'
alias tlp_perf="sudo tlp ac -- CPU_ENERGY_PERF_POLICY_ON_AC=performance"\
" MAX_LOST_WORK_SECS_ON_AC=0 CPU_SCALING_GOVERNOR_ON_AC=performance"
alias vmware_run="pkexec sh -c 'systemctl start vmware-networks"\
"&& modprobe -a vmw_vmci vmmon' && vmware 1>&2 2>&- &"
alias vmware_stop="pkexec sh -c 'systemctl stop vmware-networks"\
" && rmmod vmw_vsock_vmci_transport vmw_vmci vmmon'"

# functions
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
    ps aux | grep -v grep | grep --color=auto "$1"
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
