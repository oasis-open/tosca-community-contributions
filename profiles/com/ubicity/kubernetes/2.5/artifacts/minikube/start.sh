#!/bin/bash

#
# Start Minikube Cluster
#

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

require_inputs public_address

# Minikube profile names only allow alphanumerics and dashes
sudo systemctl enable kubelet || true
sudo minikube start --driver=none --container-runtime=containerd --apiserver-ips "$public_address"

# Keys and certificates are stored in /home/miniusers/.minikube/profiles/<name>
