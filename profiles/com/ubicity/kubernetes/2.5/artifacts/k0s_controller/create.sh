#!/bin/bash

#
# Install k0s on Linux
#

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

init_output

# Download and install the k0s binary
curl -sSLf https://get.k0s.sh | sudo sh

# Clean up any previous installation before reinstalling
sudo k0s stop || true
sudo pkill -f k0s || true
sudo k0s reset || true
sudo rm -rf /var/lib/k0s /etc/k0s

# Install k0s as a controller with worker role enabled
sudo k0s install controller --enable-worker
