#!/bin/bash

#
# Stop K3s on Linux
#

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

init_output

cd /tmp
sudo /usr/local/bin/k3s-killall.sh
