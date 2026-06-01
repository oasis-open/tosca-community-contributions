#!/bin/bash

#
# Uninstall MicroK8s
#

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

init_output

# Stop MicroK8s if running
sudo microk8s stop || true

# Remove MicroK8s and all its data
sudo snap remove microk8s --purge
