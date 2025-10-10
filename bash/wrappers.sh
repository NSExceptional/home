# Wraps other commands like python scripts located in my repos folder

bgiparser() {
    # Forward args to script, add -h if no args provided
    if [ $# -eq 0 ]; then
        args=("-h")
    else
        args=("$@")
    fi
    python3 ~/Repos/bin/bgiparser/bgiparser.py "${args[@]}"
}

