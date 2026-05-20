#!/bin/bash

#
# Uninstall K3s agent
#

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

init_output

sudo /usr/local/bin/k3s-agent-uninstall.sh
