#!/bin/bash

#
# Start k0s
#

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

init_output

sudo k0s start

# Wait for control plane to be ready
echo "Waiting for k0s control plane to initialize..."
TIMEOUT=120
ELAPSED=0
until sudo k0s kubeconfig admin > /dev/null 2>&1; do
    if [ "$ELAPSED" -ge "$TIMEOUT" ]; then
        echo "ERROR: k0s control plane did not initialize within ${TIMEOUT}s"
        sudo k0s status
        exit 1
    fi
    sleep 5
    ELAPSED=$((ELAPSED + 5))
done
