#!/bin/bash

# This script expects the following environment variables:
#
# Optional:
#
#          helm_version   (if not provided, the latest stable version is installed)

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

init_output

# If helm_version is not provided, fetch the latest stable version
if [ -z "${helm_version}" ]; then
    helm_version=$(curl -sL https://get.helm.sh/helm-latest-version | sed 's/^v//')
    echo "No helm_version specified, using latest: $helm_version"
fi

# Helm 2 is end-of-life and no longer supported
if [[ "$helm_version" == 2.* ]]; then
    echo "Helm 2 is end-of-life and not supported"
    exit 1
fi

# Map uname -m architecture to Helm release naming
case "$(uname -m)" in
    x86_64  ) ARCH="amd64" ;;
    aarch64 ) ARCH="arm64" ;;
    * ) echo "Unsupported architecture: $(uname -m)"; exit 1 ;;
esac

TARBALL="helm-v${helm_version}-linux-${ARCH}.tar.gz"
URL="https://get.helm.sh/${TARBALL}"

cd /tmp

# Download the Helm binary and checksum
wget -q "$URL"
wget -q "${URL}.sha256sum"

# Verify checksum
sha256sum -c "${TARBALL}.sha256sum"

# Unpack and install
tar -xf "$TARBALL"
sudo mv "linux-${ARCH}/helm" /usr/local/bin/helm

# Clean up
rm -rf "$TARBALL" "${TARBALL}.sha256sum" "linux-${ARCH}"

output "helm_version: $helm_version"
