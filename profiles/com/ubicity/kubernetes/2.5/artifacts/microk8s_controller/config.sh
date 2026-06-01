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

# Retrieve kubeconfig (MicroK8s uses port 16443 by default)
if ! ssh -i "${key_file}" "${user_name}@${host}" "sudo microk8s config" > "$kubeconfig"; then
    rm -f "$kubeconfig"
    echo "ERROR: Failed to retrieve kubeconfig from ${host}"
    exit 1
fi

# Update server address
sed -i "s|server: https://.*:16443|server: https://${host}:16443|" "$kubeconfig"

# Retrieve version
version=$(kubectl --kubeconfig="${kubeconfig}" version -o json 2>/dev/null | jq -r '.serverVersion.gitVersion' | sed 's/^v//;s/+.*//')

# Generate worker join token (non-expiring)
join_token=$(ssh -i "${key_file}" "${user_name}@${host}" \
    "sudo microk8s add-node --token-ttl 0 2>/dev/null | grep 'microk8s join' | head -1 | awk '{print \$NF}'")

output "kubeconfig: ${kubeconfig}"
output "version: $version"
output "join_token: $join_token"
