#!/bin/bash

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

init_output

# Delete default virtual host configuration by removing the symbolic
# link.
sudo -n rm /etc/nginx/sites-enabled/default
