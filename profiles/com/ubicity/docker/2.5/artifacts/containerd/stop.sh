#!/bin/bash
#
# This script stops Containerd
#

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

init_output

sudo systemctl stop containerd
sudo systemctl disable containerd
