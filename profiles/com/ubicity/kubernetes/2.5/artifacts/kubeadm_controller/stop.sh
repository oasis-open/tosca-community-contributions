#!/bin/bash

#
# Stop Kubernetes services on the controller node.
#

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

init_output

echo "Stopping Kubernetes services..."
sudo systemctl stop kubelet
