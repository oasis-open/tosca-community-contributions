#!/bin/bash

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

init_output

# Stop and disable the Docker service before removing data directories
sudo systemctl stop docker || true
sudo systemctl disable docker || true

# Remove docker directories
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
