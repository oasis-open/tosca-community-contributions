#!/bin/bash

#
# Uninstall Minikube
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

# Delete minikube cluster data
sudo minikube delete --purge || true

# Uninstall the minikube package and binary
sudo dpkg -r minikube || sudo rm -f /usr/local/bin/minikube
