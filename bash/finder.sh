### Finder-like utilities ###

alias bk="cd - > /dev/null"

qfree() {
    xattr -dr com.apple.quarantine "$@"
}

# Make a shortcut to the current path in my shortcuts folder
scut() {
    local cur=`pwd`
    local dir=~/Shortcuts
    ln -vs "$cur" "$dir/$@"
}

alias hide="chflags hidden"
alias unhide="chflags nohidden"

alias uicache="sudo find /private/var/folders/ -name com.apple.dock.iconcache -exec rm {} \; sudo find /private/var/folders/ -name com.apple.iconservices -exec rm -rf {} \;"

# Search for the given text in files in the current directory
search() {
    if [[ $1 ]]; then
        find . -type f -not -iwholename '*.git*' -exec grep -H "$1" {} \;
    else
        echo "Search for text in files"
    fi
    # for var in `find . -type f`
    # do
    #     grep -H $1 "$var"
    # done
}

# Search for a file by name
searchf() {
    if [[ $1 ]]; then
        find . -type f -not -iwholename '*.git*' -name "$1"
    else
        echo "Search for files by name"
    fi
}

# Search for a file by name only in the current folder
searchft() {
    if [[ $1 ]]; then
        ls | grep "$1"
    else
        echo "Search for files by name"
    fi
}

# Search for a file and only output the filename
searchfn() {
    find . -type f -not -iwholename '*.git*' -name "$1" | xargs basename
}

# Set optiont to show full path in the Finder window
alias finderfullpath="defaults write com.apple.finder _FXShowPosixPathInTitle -bool true; killall Finder"

# Creates a macOS installer drive
# Usage: createinstaller <volume name> [appPath]
createinstaller() {
    drive="/Volumes/$1"
    appPath="$2"

    if [[ ! "$1" ]]; then
        echo "Missing volume name"
    else
        if [[ ! "$appPath" ]]; then
            appPath="/Applications/Install macOS Sierra.app"
        fi

        binary="$appPath/Contents/Resources/createinstallmedia"

        echo "Volume: $drive"
        echo "App:    $appPath"
        echo "Binary: $binary"
        echo
        echo sudo \"$binary\" --volume \"$drive\" --applicationpath \"$appPath\" --nointeraction
        sudo "$binary" --volume "$drive" --applicationpath "$appPath" --nointeraction
    fi
}

mov2mp4() {
    ffmpeg -i "$1" -vcodec h264 -acodec mp2 "$1.mp4";
}

gif2mp4() {
    local filename=`basename $1 .gif`
    ffmpeg -i "$1" -movflags faststart -pix_fmt yuv420p -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" "$filename.mp4"
}

walify() {
    sqlite3 "$1" "PRAGMA wal_checkpoint(TRUNCATE);"
}
