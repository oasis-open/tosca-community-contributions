#!/bin/bash

#
# Uninstall k0s on Linux
#

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

init_output

# Stop k0s and kill any lingering processes
sudo k0s stop || true
sudo pkill -f k0s || true

# Reset k0s and remove data directories
sudo k0s reset || true
sudo rm -rf /var/lib/k0s /etc/k0s

# Remove the k0s binary
sudo rm -f /usr/local/bin/k0s
