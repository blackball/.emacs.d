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
    alias ls='ls --color=auto -shortlF'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# export LANGUAGE="en_US.UTF-8"
# export LANG=en_US.UTF-8
# export LC_ALL=C

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

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
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

# git commit and push in one line 
function gitcp() {
    if [ -z "$1" ]
    then
        echo "please provide a commit message"
    else
        git commit -m "$1"
        git push
    fi
}


export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/home/rvbust/Rvbust/Install/Miniconda3/lib:/home/rvbust/Rvbust/Install/OpenCV/lib:/home/rvbust/Rvbust/Install/OSG/lib64:/home/rvbust/Rvbust/Install/ColladaDom/lib:/home/rvbust/Rvbust/Install/GLog/lib:/home/rvbust/Rvbust/Install/GFlags/lib:/home/rvbust/Rvbust/Install/CeresSolver/lib:/home/rvbust/Rvbust/Install/RealSense/lib"

# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(openrave-config --python-dir)/openravepy/_openravepy_:/usr/local/lib64/
export PYTHONPATH="${PYTHONPATH}:/home/rvbust/Rvbust/Install/Sophus/py:/home/rvbust/Rvbust/Install/RealSense/lib"
# export PATH=$PATH:/home/hui/Downloads/clion-2017.2.2/bin
# export TEXMACS_PATH=/home/hui/Downloads/TeXmacs-1.99.5-10549M-i386-pc-linux-gnu
# export PATH=$TEXMACS_PATH/bin:$PATH

# added by Miniconda3 installer
export PATH="/home/rvbust/Rvbust/Install/Miniconda3/bin:$PATH"
alias snake="python3 /home/rvbust/Rvbust/Sources/Snake/Snake.py"

alias show="ristretto"
export COLLADA_DIR="/home/rvbust/Rvbust/Install/ColladaDom"

# copy content of a file from terminal: copytext foo.txt
alias copytext="xclip -selection clipboard < " 

# added by Miniconda3 installer
export PATH="/home/rvbust/Rvbust/Install/Miniconda3/bin:$PATH"

function runrealsense() {
    sudo docker run -it --volume=/tmp/.X11-unix:/tmp/.X11-unix --device=/dev/dri:/dev/dri --net=host --privileged -v /dev/video/ --env="DISPLAY" $1
}

alias FUCKGFW="ALL_PROXY=socks5://127.0.0.1:1080"
