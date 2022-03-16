#
# ~/.bashrc
#

[[ $- != *i* ]] && return

# shell options
[[ $DISPLAY ]] && shopt -s checkwinsize
shopt -s histappend
set -b

# variables
HISTCONTROL=erasedups
HISTSIZE=-1
HISTFILESIZE=-1
PROMPT_DIRTRIM=2
export EDITOR="vim"
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

case "$TERM" in
    *color*|alacritty)
	PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
	;;
    *)
	PS1='[\u@\h]:\w\$ '
	;;
esac

# color aliases
alias ls='ls --color=auto'
alias dir='dir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ll='ls -Alh'
alias l='ls -CAF'

# convenient aliases
alias gt="gio trash"
alias open="xdg-open"
alias prime-run='__NV_PRIME_RENDER_OFFLOAD=1 __VK_LAYER_NV_optimus=NVIDIA_only __GLX_VENDOR_LIBRARY_NAME=nvidia'
alias tlp-perf="sudo tlp ac -- CPU_ENERGY_PERF_POLICY_ON_AC=performance MAX_LOST_WORK_SECS_ON_AC=0 CPU_SCALING_GOVERNOR_ON_AC=performance"
alias video='\
      xrandr --output HDMI-1-0 --auto \
      && systemd-inhibit \
      --what=handle-lid-switch sleep 1d'
alias bluetooth='\
      sudo modprobe btusb\
      && sudo systemctl start bluetooth\
      && bluetoothctl;\
      sudo systemctl stop bluetooth;\
      sudo rmmod btusb'

# functions
docker_latest(){
	sudo docker ps | head -2 | tail -1 | cut -d' ' -f 1
}

docker_connect(){
	sudo docker exec -it "$(docker_latest)" bash
}

pdf_grayscale(){
    gs \
   -sDEVICE=pdfwrite \
   -sProcessColorModel=DeviceGray \
   -sColorConversionStrategy=Gray \
   -dOverrideICC \
   -o $2 \
   -f $1
}

mcd(){
    mkdir "$1" && cd "$1"
}

psgrep (){
    ps aux | grep --color=auto "$1" | grep --color=auto -v grep
}

# emacs
if [[ "${INSIDE_EMACS}" == *"comint"* ]]; then
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
fi
