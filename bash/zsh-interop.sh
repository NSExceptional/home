#
#  zsh-interop.sh
#  bash
#  
#  Created by Tanner Bennett on 2024-12-26
#  Copyright © 2024 Tanner Bennett. All rights reserved.
#

# Calls a zsh function from bash, using the caller's name as the function name.
# Arguments are forwarded to the zsh function.
function zsh_invoke() {
    # By default, guess the caller's name from FUNCNAME[1].
    local caller_name="${FUNCNAME[1]}"

    zsh -c "
        for f in ~/bash/*.zsh; do source \"\$f\"; done
        \"$caller_name\" \"\$@\"
    " -- "$@"
}
