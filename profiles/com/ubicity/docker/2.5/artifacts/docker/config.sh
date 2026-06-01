#!/bin/bash
#
# This script configures Docker Community Edition. Based on
#
# https://docs.docker.com/engine/install/ubuntu/
#
# Refer to https://docs.docker.com/engine/installation/ for more information
#
# LOG_FILE and USER are set by the artifact processor

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

init_output

## Add the user to the 'docker' group. Docker group may already exist.
sudo -n groupadd docker || true
sudo usermod -aG docker "$USER"
