#!/bin/bash

# Script to install virtctl for KubeVirt

set -e

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

require_inputs() {
    local missing=()
    for var_name in "$@"; do
        local var_value="${!var_name:-}"
        if [ -z "$var_value" ]; then
            missing+=("$var_name")
        fi
    done
    if [ ${#missing[@]} -gt 0 ]; then
        echo "Missing mandatory inputs: ${missing[*]}"
        exit 10
    fi
}

init_output

require_inputs version

echo "Installing virtctl version: $version"
VIRTCTL_VERSION=v${version}

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

# Map architecture names
case $ARCH in
    x86_64)
        ARCH="amd64"
        ;;
    aarch64|arm64)
        ARCH="arm64"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

PLATFORM="${OS}-${ARCH}"

# Download virtctl
DOWNLOAD_URL="https://github.com/kubevirt/kubevirt/releases/download/${VIRTCTL_VERSION}/virtctl-${VIRTCTL_VERSION}-${PLATFORM}"
echo "Downloading from: $DOWNLOAD_URL"

curl -L -o /tmp/virtctl "$DOWNLOAD_URL"

# Make it executable
chmod +x /tmp/virtctl

# Install to /usr/local/bin
echo "Installing virtctl to /usr/local/bin..."
sudo mv /tmp/virtctl /usr/local/bin/virtctl

# Verify installation
if command -v virtctl &> /dev/null; then
    echo "✓ virtctl installed successfully!"
    virtctl version --client
else
    echo "Error: virtctl installation failed"
    exit 1
fi

echo "Installation complete!"
output "version: ${version}"
