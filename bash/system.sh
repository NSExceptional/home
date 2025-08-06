### System/OS related utilities ###

# Checks if System Integrity Protection is on
alias sip="csrutil status"

# Clears UI cache
alias uicache="sudo find /private/var/folders/ -name com.apple.dock.iconcache -exec rm {} \; sudo find /private/var/folders/ -name com.apple.iconservices -exec rm -rf {} \;"

alias bootcamp="sudo nvram InstallWindowsUEFI=1; echo You may now restart your computer."

alias rm="trash -F"

alias reboot="sudo shutdown -r now"

alias fs_usage="sudo fs_usage"
_fsusage() {
    local regex="/(Applications|System|Library|Users|opt|sbin|usr|bin)/"
    fs_usage -w "$1" | grep -E $regex | sed 's/\[  [0-9]\]//g' | awk '{$1=$2=$4=$5=""; print $0}'
}

fsusage() {
    if [[ $1 ]]; then
        if [[ $2 ]]; then
            if [[ $3 ]]; then
                if [[ $4 ]]; then
                    _fsusage "$1" | grep "$2" | grep "$3" | grep "$4"
                    return
                fi
                
                _fsusage "$1" | grep "$2" | grep "$3"
                return
            fi
                
            _fsusage "$1" | grep "$2"
            return
        fi
                
        _fsusage "$1"
        return
    fi
}

# alias ps="ps -ef | grep "
