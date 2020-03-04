# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls -hltr --color=auto'
    alias lsr='ls -dR $PWD/*'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# NOTE: these path appending also happens in .profile, since
# terminal opened in GUI env. is not a login shell, it will not run .profile file. 
# if running bash
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi


parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1="\u@\h \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "

# display pwd on title
PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'

# alias open folder
alias opencd="xdg-open ."

function listimages() {
    sudo docker images 
}

# run docker with GUI enabled
function runimage() {
    echo "xhost +local:root"
    xhost +local:root 
    sudo docker run -it -p 5180:5180 -e "DISPLAY=unix:0.0" -v="/tmp/.X11-unix:/tmp/.X11-unix:rw" --privileged --net=host "$1" bash
}

alias cleanupdocker=' \
  sudo docker container prune -f ; \
  sudo docker image prune -f ; \
  sudo docker network prune -f ; \
  sudo docker volume prune -f '

# run docker with GUI enabled
# function runimagesr300() {
#     sudo docker run -it -p 5180:5180 \
#          -e "DISPLAY=unix:0.0" \
#          -v="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
#          --device=/dev/video0:/dev/video0 \
#          --device=/dev/video1:/dev/video1 \
#          --device=/dev/video2:/dev/video2 \
#          --device=/dev/video3:/dev/video3 \
#          --privileged --net=host "$1" bash
# }

function commitimage() {
    # $1: container id, $2 new_image_name:tag_name
    sudo docker commit $1 $2
}

function attachcontainer() {
    sudo docker exec -i -t $1 /bin/bash
}

alias snake="python3 /home/rvbust/Rvbust/Sources/Snake/Snake.py"
complete -W "build install list setup updateserver vpn" snake

alias FUCKGFW="ALL_PROXY=socks5://127.0.0.1:10808"

alias ipython="python3 -m IPython"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/home/rvbust/Rvbust/Install/OSG/lib"
export PYTHONPATH="$PYTHONPATH:/home/rvbust/Rvbust/Install/RVS/Lib/Python"
alias rm="safe-rm"
source ~/.cargo/env

# To prevent warnings when start Emacs. 
export NO_AT_BRIDGE=1
alias extract=dtrx 
alias sss="PROMPT_DIRTRIM=3"

alias elsrun="~/WS/Github/Sandbox/EmacsSplitLine/EmacsSplitLine"
function em() {
    file=$(elsrun 0 $1)
    line=$(elsrun 1 $1)
    column=$(elsrun 2 $1)

    if test -z "$file"
    then
        emacs
        return 
    fi
    
    if [ "$line" == "0" ] && [ "$column" == "0" ]
    then
        emacs "$file"
    else
        emacs "+$line:$column" "$file"
    fi
}
