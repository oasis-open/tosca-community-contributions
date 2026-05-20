#!/bin/bash

# Uninstall Helm by removing the binary.

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

init_output

sudo rm -f /usr/local/bin/helm

# Remove user-specific Helm data
rm -rf ~/.cache/helm
rm -rf ~/.config/helm
rm -rf ~/.local/share/helm
