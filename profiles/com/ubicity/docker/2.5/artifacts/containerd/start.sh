#!/bin/bash
#
# This script starts Containerd CE
#
# Copied from
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/
#
# Refer to https://docs.docker.com/engine/installation/ for more information
#

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

init_output

# Enable and start containerd
sudo systemctl enable containerd
sudo systemctl restart containerd
