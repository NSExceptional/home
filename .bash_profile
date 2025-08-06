# This file sets up commands for adding
# stuff to $PATH easily, and executes ~/.bashrc

__debug_enabled=0
__mark() {
    if [[ $__debug_enabled -eq 1 ]]
    then
        # Echo time as precise as possible
        echo "[${BASH_SOURCE[1]}][$(date +'%s.%N')] $@"
    fi
}

__mark Start

# For adding stuff to the PATH variable temporarily
addpath() {
    if [[ "$1" ]]
    then
        local p="$1"
        
        # Expand tilde first
        if [[ "$1" == "~"* ]]
        then
            p=`eval echo "$1"`
        fi
        
        export PATH="$p":"$PATH"
    fi
}

# For adding stuff to the PATH variable permenantly
addtopath() {
    if [[ "$1" ]] && [[ "$2" ]]; then
        echo Comment: "# $1"
        echo Path: "$2"
        
        addpath "$2"
        
        echo "" >> ~/.PATH
        echo "# $1" >> ~/.PATH
        echo "addpath $2" >> ~/.PATH
    else
        echo Must give a comment and a path, each quoted
    fi
}

export SHORTCUTS=~/Shortcuts

# No duplicate commands in bash history
export HISTCONTROL=ignoreboth:erasedups

__mark Source .PATH and .bashrc

. ~/.PATH
. ~/.bashrc

__mark Source completion

# Bash completion
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

# Don't highlight on paste
if [ -t 1 ] && [ -n "$PS1" ]; then
    bind 'set enable-bracketed-paste off'
fi

# opam configuration
# test -r /Users/tanner/.opam/opam-init/init.sh && . /Users/tanner/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true

# MacPorts Installer addition on 2020-02-05_at_09:59:34: adding an appropriate MANPATH variable for use with MacPorts.
export MANPATH="/opt/local/share/man:$MANPATH"

if [[ $PWD == $(realpath ~) ]]; then
    cd ~/Desktop/
fi

__mark End
. "/Users/tanner/.deno/env"