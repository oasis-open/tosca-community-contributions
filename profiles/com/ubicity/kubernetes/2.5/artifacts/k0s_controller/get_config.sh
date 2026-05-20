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

# Retrieve kubeconfig
if ! ssh -i "${key_file}" "${user_name}@${host}" "sudo k0s kubeconfig admin" > "$kubeconfig"; then
    rm -f "$kubeconfig"
    echo "ERROR: Failed to retrieve kubeconfig from ${host}"
    exit 1
fi

# Update server address
sed -i "s|server: https://.*:6443|server: https://${host}:6443|" "$kubeconfig"

# Retrieve version
version=$(kubectl --kubeconfig="${kubeconfig}" version -o json 2>/dev/null | jq -r '.serverVersion.gitVersion' | sed 's/^v//;s/+.*//')

# Wait for a Ready node to appear (kubectl wait fails immediately if no nodes exist yet)
echo "Waiting for node to become Ready..."
until kubectl --kubeconfig="${kubeconfig}" get nodes 2>/dev/null | grep -q " Ready"; do
    sleep 5
done

# Remove control-plane taints so workloads can be scheduled on this node
kubectl --kubeconfig="${kubeconfig}" taint nodes --all node-role.kubernetes.io/control-plane:NoSchedule- || true
kubectl --kubeconfig="${kubeconfig}" taint nodes --all node-role.kubernetes.io/master:NoSchedule- 2>/dev/null || true

# Generate worker join token (1 year expiry)
join_token=$(ssh -i "${key_file}" "${user_name}@${host}" "sudo k0s token create --role=worker --expiry=8760h" | tr -d '\n')

output "kubeconfig: ${kubeconfig}"
output "version: $version"
output "join_token: $join_token"
