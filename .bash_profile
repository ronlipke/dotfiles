#!/usr/bin/env bash

# Ensure user-installed & homebrew binaries take precedence
export PATH="$(brew --prefix coreutils)/libexec/gnubin:/usr/local/bin:/usr/local/sbin:~/bin:~/go/bin:$PATH"

# Load .bashrc if it exits
test -f ~/.bashrc && source ~/.bashrc

# Load .bash_envs if it exits
test -f ~/.bash_envs && source ~/.bash_envs

## Functions

# random number
function rand() {
  if [ "$1" -gt "32767" ]; then
    echo "Choose a number from 1-32767"
  else
    FLOOR=1;
    RANGE=$1
    RESULT=$RANDOM;
    let "RESULT %= $RANGE";
    RESULT=$(($RESULT+$FLOOR));
    echo $RESULT
   fi 
}

# cd to the path of the front Finder window
cdf() {
    target=`osascript -e 'tell application "Finder" to if (count of Finder windows) > 0 then get POSIX path of (target of front Finder window as text)'`
    if [ "$target" != "" ]; then
        cd "$target"; pwd
    else
        echo 'No Finder window found' >&2
    fi
}

ff () { /usr/bin/find . -name "$@" ; }      # ff: Find file under the current directory
ffs () { /usr/bin/find . -name "$@"'*' ; }  # ffs: Find file whose name starts with a given string
ffe () { /usr/bin/find . -name '*'"$@" ; }  # ffe: Find file whose name ends with a given string

# unarchive different file formats
extract() {
    if [ -f $1 ] ; then
      case $1 in
        *.tar.bz2)   tar xjf $1     ;;
        *.tar.gz)    tar xzf $1     ;;
        *.bz2)       bunzip2 $1     ;;
        *.rar)       unrar e $1     ;;
        *.gz)        gunzip $1      ;;
        *.tar)       tar xf $1      ;;
        *.tbz2)      tar xjf $1     ;;
        *.tgz)       tar xzf $1     ;;
        *.zip)       unzip $1       ;;
        *.Z)         uncompress $1  ;;
        *.7z)        7z x $1        ;;
        *)     echo "'$1' cannot be extracted via extract()" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}

# make a directory and cd into it
mcd() { mkdir -p "$1" && cd "$1"; }

# color manpages - http://boredzo.org/blog/archives/2016-08-15/colorized-man-pages-understood-and-customized
man() {
    env \
        LESS_TERMCAP_md=$'\e[1;34m' \
        LESS_TERMCAP_me=$'\e[0m' \
        LESS_TERMCAP_se=$'\e[0m' \
        LESS_TERMCAP_so=$'\e[1;40;92m' \
        LESS_TERMCAP_ue=$'\e[0m' \
        LESS_TERMCAP_us=$'\e[1;32m' \
            man "$@"
}

# ii: display useful host related informaton
ii() {
    echo -e "\nYou are logged on ${RED}$HOST"
    echo -e "\nAdditionnal information:$NC " ; uname -a
    echo -e "\n${RED}Users logged on:$NC " ; w -h
    echo -e "\n${RED}Current date :$NC " ; date
    echo -e "\n${RED}Machine stats :$NC " ; uptime
    echo -e "\n${RED}Public facing IP Address :$NC " ;myip
    echo
}

## Aliases

alias sizes="du -sh * | sort -hr"
alias speedtest="speed-test"
alias diga='dig +noall +answer'
alias digs='dig +noall +short'
alias fuck='sudo $(history -p \!\!)'
alias f='open -a Finder ./'
alias ls='gls -N --color=tty'
alias ll='gls -NFlAhp'
alias lt='gls -NFlAhpt'
alias less='less -FRXc'
alias con='tail -40 -f /var/log/system.log'
alias subl='subl -n'
alias atom='atom -n'
alias code='code -n'
alias yolo='git checkout -b yolo'
alias cebe='chef exec bundle exec'
alias ck='chef exec bundle exec kitchen'
alias cp='cp -iv'
alias mv='mv -iv'
alias mkdir='mkdir -pv'
alias ~="cd ~"
alias ttop="top -R -F -s 10 -o rsize"
alias weather="curl -4 wttr.in"
alias thingsbitica='envchain habitica bash -c "/opt/repos/things-bitica/thingsbitica.sh"'
alias myip='dig @resolver1.opendns.com myip.opendns.com +short'
alias netCons='lsof -i'                             # netCons:      Show all open TCP/IP sockets
alias flushDNS='dscacheutil -flushcache'            # flushDNS:     Flush out the DNS Cache
alias lsock='sudo /usr/sbin/lsof -i -P'             # lsock:        Display open sockets
alias lsockU='sudo /usr/sbin/lsof -nP | grep UDP'   # lsockU:       Display only open UDP sockets
alias lsockT='sudo /usr/sbin/lsof -nP | grep TCP'   # lsockT:       Display only open TCP sockets
alias ipInfo0='ipconfig getpacket en0'              # ipInfo0:      Get info on connections for en0
alias ipInfo1='ipconfig getpacket en1'              # ipInfo1:      Get info on connections for en1
alias openPorts='sudo lsof -i | grep LISTEN'        # openPorts:    All listening connections

## Environment Variables

HISTCONTROL=ignoreboth:erasedups
HISTSIZE=1000000
HISTTIMEFORMAT="%h %d %H:%M:%S → "
PROMPT_COMMAND='echo -ne "\033]0;${PWD/#$HOME/~}\007"'
shopt -s histappend
export EDITOR="code -nw"
export GIT_EDITOR='code -nw'
export GOPATH="$HOME/go"

# Don't check mail when opening terminal.
unset MAILCHECK

# bash-completion via homebrew
if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi

# load ssh
if [ ! -S ~/.ssh/ssh_auth_sock ]; then
  eval `ssh-agent`
  ln -sf "$SSH_AUTH_SOCK" ~/.ssh/ssh_auth_sock
fi
export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock
ssh-add -l | grep "The agent has no identities" && ssh-add

# Better history search - start typing command then use up/down arrows
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

if [ -f "$(brew --prefix bash-git-prompt)/share/gitprompt.sh" ]; then
    GIT_PROMPT_THEME=Single_line
    source "$(brew --prefix bash-git-prompt)/share/gitprompt.sh"
fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/opt/repos/y/google-cloud-sdk/path.bash.inc' ]; then source '/opt/repos/y/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/opt/repos/y/google-cloud-sdk/completion.bash.inc' ]; then source '/opt/repos/y/google-cloud-sdk/completion.bash.inc'; fi
