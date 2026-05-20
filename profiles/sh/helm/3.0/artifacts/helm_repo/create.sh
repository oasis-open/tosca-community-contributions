#!/bin/bash

# This script expects the following Environment Variables:
#
#          repo_name
#          repo_url

# LOG_FILE is set by the Executor

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

require_inputs repo_name repo_url

# Add the helm repo
helm repo add "$repo_name" "$repo_url"
