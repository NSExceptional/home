#
#  scripts.sh
#  bash
#  
#  Created by Tanner Bennett on 2021-06-29
#  Copyright © 2021 Tanner Bennett. All rights reserved.
#

aotdl() {
    local login="-u bruiser@me.com -p 20132817tT!"
    local cookies="--cookies ~/Desktop/funimation_cookies.txt"
    local url="https://www.funimation.com/en/shows/$1?lang=English"
    youtube-dl $login $cookies $url
}

aotdlall() {
    if [[ ! -f episodes.txt ]]; then
        echo "No episodes.txt; aborting"
    else
        for ep in `cat episodes.txt`; do
            aotdl $ep
        done
    fi
}
