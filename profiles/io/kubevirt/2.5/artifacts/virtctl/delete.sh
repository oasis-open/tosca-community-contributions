#!/bin/bash

# Script to uninstall virtctl

set -e

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

init_output

echo "Uninstalling virtctl..."

# Check if virtctl is installed
if ! command -v virtctl &> /dev/null; then
    echo "virtctl is not installed or not in PATH"
    exit 0
fi

# Get virtctl location
VIRTCTL_PATH=$(which virtctl)
echo "Found virtctl at: $VIRTCTL_PATH"

# Remove virtctl
echo "Removing virtctl..."
sudo rm -f "$VIRTCTL_PATH"

# Verify removal
if command -v virtctl &> /dev/null; then
    echo "Warning: virtctl still found in PATH at $(which virtctl)"
    echo "You may have multiple installations. Please check:"
    echo "  - /usr/local/bin/virtctl"
    echo "  - /usr/bin/virtctl"
    echo "  - ~/.local/bin/virtctl"
else
    echo "✓ virtctl uninstalled successfully!"
fi

echo "Uninstallation complete!"
