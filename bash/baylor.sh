#
#  baylor.sh
#  bash
#  
#  Created by Tanner Bennett on 2024-12-26
#  Copyright © 2024 Tanner Bennett. All rights reserved.
#

return;

alias fire='cls; ssh bennettt@fire.ecs.baylor.edu'
firecp() {
    src=bennettt@wind.ecs.baylor.edu:$1
    dest=$2
    scp $src $dest
}
firecpr() {
    src=bennettt@wind.ecs.baylor.edu:$1
    dest=$2
    scp -r $src $dest
}
firecpto() {
    src=$1
    dest=bennettt@wind.ecs.baylor.edu:$2
    scp $src $dest
}
firecptor() {
    src=$1
    dest=bennettt@wind.ecs.baylor.edu:$2
    scp -r $src $dest
}