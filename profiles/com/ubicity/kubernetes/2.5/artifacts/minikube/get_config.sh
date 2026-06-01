#!/bin/bash

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

expand_path() {
    echo "${1//\~/$HOME}"
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

require_inputs host user vault

# Retrieve the user name and key file name
user_name=$(jq -r '.user_name' <<< "$user")
file_name=$(jq -r '.key_file' <<< "$user")

require_inputs user_name file_name

key_file=$(expand_path "$file_name")
VAULT=$(expand_path "$vault")

# Make sure vault exists
if [ ! -d "${VAULT}" ]; then
    sudo mkdir -p "${VAULT}"
    USER_NAME=$(id -un)
    GROUP_NAME=$(id -gn)
    sudo chown "${USER_NAME}.${GROUP_NAME}" "${VAULT}"
fi

# Process optional input values
if [ -z "${kubeconfig}" ]; then
    SALT=$(md5sum <<< "$RANDOM" | head -c 10)
    kubeconfig="${VAULT}/kubeconfig-${SALT}"
fi

# Retrieve kubeconfig with certificates embedded inline (not as file references)
if ! ssh -i "${key_file}" "${user_name}@${host}" "sudo minikube kubectl -- config view --flatten" > "$kubeconfig"; then
    rm -f "$kubeconfig"
    echo "ERROR: Failed to retrieve kubeconfig from ${host}"
    exit 1
fi

# Update server address (minikube binds to internal IP; patch to public address)
sed -i "s|server: https://.*:8443|server: https://${host}:8443|" "$kubeconfig"

# Retrieve version
version=$(kubectl --kubeconfig="${kubeconfig}" version -o json 2>/dev/null | jq -r '.serverVersion.gitVersion' | sed 's/^v//;s/+.*//')

output "kubeconfig: ${kubeconfig}"
output "version: $version"
