#!/bin/bash

#
# Uninstall k0s worker
#

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

init_output

sudo k0s stop || true
sudo k0s reset
sudo rm -f /usr/local/bin/k0s
