#!/bin/bash

#
# Configure Minikube on Linux
#

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

init_output

# Create the 'minikube' user account. The '-m' flag makes sure that
# the home directory is created.
sudo useradd -m miniuser

# Add the 'minkube' user account to the 'docker' group
sudo usermod -aG docker miniuser
