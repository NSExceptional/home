#
#  .bashrc
#  tanner
#  
#  Created by Tanner Bennett on 2020-01-31
#  Copyright © 2024 Tanner Bennett. All rights reserved.
#

__mark Start

### Editing ###

# Like `vim`
tim() {
    touch $1; open -a Code $1
}

### Bash helpers ###
alias rc="tim ~/.bashrc"
alias profile="tim ~/.bash_profile"
alias history="tim ~/.bash_history"
alias path="tim ~/.PATH"
alias refresh=". ~/.bash_profile"
alias cls="clear; clear"
alias ls="ls -FG"
alias lsl="ls -1"
alias mkdir="mkdir -p"
alias wget="wget -q --show-progress"
alias pwd="pwd -P"

### Includes ###
include() {
    if [[ "$1" ]]; then
        . "$1"
    fi
}

__mark Source ~/bash scripts

# Include files
for file in ~/bash/*.sh; do
    if [[ $__debug_enabled -eq 1 ]]; then
        echo "    $file"
    fi
    
    include "$file"
done

# Open included file
re() {
    if [[ "$1" ]]; then
        tim ~/bash/"$1".sh
    else
        lsl ~/bash
    fi
}

### Variables ###

export TEXDIR=/Library/TeX/texlive/2021
export MANPATH=`manpath`:/Users/tanner/man/ubuntu:$TEXDIR/texmf-dist/doc/man
export HISTFILESIZE=20000
export GH_NO_UPDATE_NOTIFIER=1
export HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK=1
export HOMEBREW_NO_ENV_HINTS=1

# ls colors
export LSCOLORS='gxfxcxdxbxegedabagacad'

### Misc helpers ###

alias pcopy=pbcopy
alias ppaste=pbpaste
alias highp="sudo renice -20"
rchmod() {
    stat -f "%Lp" "$1"
}

which() {
    local result
    result=$(type -p "$@")
    if [[ -n "$result" ]]; then
        echo "$result"
    else
        type "$@"
    fi
}

__lazy_load_nvm() {
    echo Sourcing NVM…
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
}

nvm() {
    unset -f nvm
    __lazy_load_nvm
    nvm "$@"
}

npm() {
    unset -f npm
    __lazy_load_nvm
    npm "$@"
}

node() {
    unset -f node
    __lazy_load_nvm
    node "$@"
}

# In non-interactive shells, load nvm immediately
if [[ $- != *i* ]]; then
    __lazy_load_nvm
fi

__mark End
. "/Users/tanner/.deno/env"
