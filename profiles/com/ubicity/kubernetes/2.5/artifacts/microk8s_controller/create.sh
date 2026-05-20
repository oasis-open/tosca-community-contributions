#!/bin/bash

#
# Install MicroK8s on Linux via snap
#

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

init_output

# Install MicroK8s
sudo snap install microk8s --classic

# Wait for MicroK8s to be ready
sudo microk8s status --wait-ready
