#!/usr/bin/env zsh
# Fancy new zsh!
#
# Thu Sep 27 02:00:44 CEST 2007
#
# Aleksandar Dimitrov

set -o vi

### Environment

export VISUAL=/usr/bin/vim
export EDITOR=/usr/bin/vim
HISTFILE=~/.history
HISTSIZE=4000
SAVEHIST=2000
DIRSTACKSIZE=10

setopt histlexwords
setopt incappendhistory
setopt dvorak
setopt correct
setopt extendedhistory
setopt extended_glob
setopt histignoredups
setopt histallowclobber
setopt histignorespace
setopt autopushd
setopt noclobber
setopt autocd

alias ls='ls --color="auto" -CFB'

alias ll='ls -lh' la='ls -A' lsd='ls -d' l='ls'
alias vi=vim
alias grep='grep --color="auto"'
alias mkdir='nocorrect mkdir -p' touch 'nocorrect touch'
alias du='du -h' df='df -h'
alias vim='vim -p'
alias ccp="rsync -rvau --info=progress2 --partial"
alias no='ls'
alias on='sl'

alias rm='rm -iv'
alias mv='mv -i'
alias cp='cp -i'

autoload -U compinit && compinit
zstyle ':completion:*' menu select=10
zstyle ':completion:*:*:kill:*:processes' command 'ps --forest -e -o pid,user,tty,cmd'

autoload -U zmv

### Keybindings
###############

# history

bindkey '^p' history-beginning-search-backward
bindkey '^n' history-beginning-search-forward
bindkey '^r' history-incremental-pattern-search-backward
bindkey -M vicmd '?' history-incremental-search-backward

# undo
bindkey -a u undo
bindkey -M vicmd '^R' redo

### Functions

## Autoload
autoload -U zmv

fork() { (setsid "$@" &); }

# move stuff to a directory and c there
m() {
	mv $@
	if [ $? -eq 0 ] # -a -d $@[-1] ]
	then
		if [ -d $@[-1] ];
		then 
			c $@[-1]
		fi
	fi
}

# cd to a directory and create it, when neccessary
# and list what's in it
c() {
	if [ ! $1 = "-" -a ! -d $1 ]; then
		print "cdp: Creating $1"
		mkdir -p $1
	fi
	cd $@
	if [ $? -eq 0 ]; then ls; fi
}

# Vim addiction
vimIsAwesome() { print "You're not in vim!"; }
:w() { vimIsAwesome; }
:wq() { vimIsAwesome; }
:q() { vimIsAwesome; }

# Make ESC idempotent in vi mode
# Note: vicmd (vi command mode) in zsh doesn't have ESC bound at all, so it
# gets handed to zle, which does unexpected things with it (i.e. it expects
# another key stroke.)
noop () { }
zle -N noop
bindkey -M vicmd '\e' noop

# Make a directory that will be tracked, but its content ignored by git
mkgitigndir () {
	mkdir $1
	echo "*" >| $1/.gitignore
	echo "!.gitignore" >> $1/.gitignore
}

autoload -U zmv

updong() {
	/usr/bin/uptime | perl -ne "/(\d+) d/;print 8,q(=)x\$1,\"D\n\""
}

### Cache
zstyle ':completion::complete:*' use-cache 1

PROMPTHOST="%m "

## Prompt
autoload -U colors
colors

color() { echo "%{${fg[$1]}%}" }
CLDF="$(color 'default')"

maybe_hostname="$(color 'blue')${PROMPTHOST:-}$CLDF"
maybe_backgroundprocess="%1(j.$(color 'yellow')%j$CLDF .)"
maybe_errorcode="%(?..%B$(color 'red')%?%b$CLDF )"
user_prompt="%(#.%B$(color 'red').$(color green))%#%b"

PROMPTCHAR="$(color 'cyan')>$CLDF"
NORMALCHAR="$(color 'yellow')|$CLDF"

export SPROMPT="zsh: correct $(color 'red')%B%R%b$CLDF to $(color 'green')%B%r%b$CLDF [nyae]?"

TEMPPS1="\
$maybe_hostname\
$maybe_backgroundprocess\
$maybe_errorcode\
$user_prompt\
$CLDF" #switch to default color for rest of line.

PS1="$TEMPPS1$PROMPTCHAR "

function zle-line-init zle-keymap-select {
    PS1="$TEMPPS1${${KEYMAP/vicmd/$NORMALCHAR}/(main|viins)/$PROMPTCHAR} "
    PS2="$(color 'blue')%_ ${${KEYMAP/vicmd/$NORMALCHAR}/(main|viins)/$PROMPTCHAR} "
    zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select

autoload -U edit-command-line
zle -N edit-command-line
bindkey '\ee' edit-command-line

RPS1="$(color blue)%~$CLDF"

localfile=$HOME/.zshrc.local
if [ -f $localfile ]; then
	source $localfile
fi
