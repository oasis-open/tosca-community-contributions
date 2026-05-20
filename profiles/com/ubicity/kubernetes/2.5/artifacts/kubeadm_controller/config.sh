#!/bin/bash

#
# Retrieve kubeconfig and join token from the kubeadm controller.
#

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
        if [ -z "${!var_name:-}" ]; then
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
    sudo chown ${USER_NAME}.${GROUP_NAME} "${VAULT}"
fi

# Generate kubeconfig path if not provided
if [ -z "${kubeconfig:-}" ]; then
    SALT=$(md5sum <<<$RANDOM | head -c 10)
    kubeconfig="${VAULT}/kubeconfig-${SALT}"
fi

# Retrieve kubeconfig from the controller
if ! ssh -i "${key_file}" "${user_name}@${host}" "sudo cat /etc/kubernetes/admin.conf" > "$kubeconfig"; then
    rm -f "$kubeconfig"
    echo "ERROR: Failed to retrieve kubeconfig from ${host}"
    exit 1
fi

# Update server address to use the public IP
sed -i "s|server: https://.*:6443|server: https://${host}:6443|" "$kubeconfig"

# Retrieve version
version=$(kubectl --kubeconfig="${kubeconfig}" version -o json 2>/dev/null \
    | jq -r '.serverVersion.gitVersion' | sed 's/^v//;s/+.*//')

# Generate a join token for worker nodes
join_token=$(ssh -i "${key_file}" "${user_name}@${host}" \
    "sudo kubeadm token create --print-join-command" 2>/dev/null)

output "kubeconfig: ${kubeconfig}"
output "version: $version"
output "join_token: $join_token"
