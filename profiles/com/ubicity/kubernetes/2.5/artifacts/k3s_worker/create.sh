#!/bin/bash

#
# Install K3s as an agent and join the cluster
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

require_inputs controller_address join_token

curl -sfL https://get.k3s.io | \
    K3S_URL="https://${controller_address}:6443" \
    K3S_TOKEN="${join_token}" \
    sh -s - agent
