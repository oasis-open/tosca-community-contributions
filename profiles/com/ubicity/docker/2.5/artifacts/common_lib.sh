#!/bin/bash
#
# Common library

init_output() {
    # Save original stdout and redirect to log file
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() {
	echo "$@" >&3
    }
}

# Validate multiple mandatory inputs at once
# Usage: require_inputs name image namespace
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

