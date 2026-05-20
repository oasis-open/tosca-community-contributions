#!/bin/bash

#
# Install k0s and configure as a worker node
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

require_inputs join_token

# Download and install the k0s binary
curl -sSLf https://get.k0s.sh | sudo sh

# Write join token to a temp file and install worker
TOKEN_FILE=$(mktemp)
echo "${join_token}" | sudo tee "$TOKEN_FILE" > /dev/null
sudo k0s install worker --token-file "$TOKEN_FILE"
rm -f "$TOKEN_FILE"
