#!/bin/bash

#
# Install MicroK8s on a worker node
#

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

init_output

sudo snap install microk8s --classic
sudo microk8s status --wait-ready
