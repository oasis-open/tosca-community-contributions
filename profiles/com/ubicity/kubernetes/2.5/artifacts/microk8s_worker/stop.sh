#!/bin/bash

#
# Stop MicroK8s worker
#

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

init_output

sudo microk8s stop
