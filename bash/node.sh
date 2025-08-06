
usaget() {
    nearleyc '/Users/tanner/bash/ts/usage.ne' -o usage.cjs
    nearley-test -q -i "$1" usage.cjs > parsed.js
}
