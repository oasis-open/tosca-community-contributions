#!/bin/bash

# Create an AKS cluster.
#
# Mandatory Environment Variables:
#
#     az_credentials_file
#     az_group_name
#     az_region_name
#     aks_cluster_name
#     aks_node_count
#     aks_dns_prefix
#     vault
#
# Optional Environment Variables:
#
#     kubeconfig
#
#     virtual_env
#     aks_version
#     aks_vm_size
#     aks_disk_size
#     aks_tier
#     aks_os_sku
#     aks_network_plugin
#     aks_load_balancer_sku
#     aks_vnet_subnet_id
#     aks_private_cluster
#     aks_max_pods_per_node
#     aks_autoscaling
#     aks_min_nodes
#     aks_max_nodes

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs az_credentials_file az_group_name az_region_name \
               aks_cluster_name aks_node_count aks_dns_prefix vault

VAULT=$(expand_path "$vault")

# Make sure vault exists
if [ ! -d "${VAULT}" ]; then
    sudo mkdir -p "${VAULT}"
    USER_NAME=$(id -un)
    GROUP_NAME=$(id -gn)
    sudo chown ${USER_NAME}.${GROUP_NAME} "${VAULT}"
fi

# ---------------------------------------------------------------------------
# Build the create command
# ---------------------------------------------------------------------------
ARGS=(
    --resource-group "$az_group_name"
    --name "$aks_cluster_name"
    --location "$az_region_name"
    --node-count "$aks_node_count"
    --dns-name-prefix "$aks_dns_prefix"
    --generate-ssh-keys
)

[ -n "${aks_version:-}" ]          && ARGS+=(--kubernetes-version "$aks_version")
[ -n "${aks_vm_size:-}" ]          && ARGS+=(--node-vm-size "$aks_vm_size")
[ -n "${aks_disk_size:-}" ]        && ARGS+=(--node-osdisk-size-gb "$aks_disk_size")
[ -n "${aks_tier:-}" ]             && ARGS+=(--tier "$aks_tier")
[ -n "${aks_os_sku:-}" ]           && ARGS+=(--os-sku "$aks_os_sku")
[ -n "${aks_network_plugin:-}" ]   && ARGS+=(--network-plugin "$aks_network_plugin")
[ -n "${aks_load_balancer_sku:-}" ] && ARGS+=(--load-balancer-sku "$aks_load_balancer_sku")
[ -n "${aks_vnet_subnet_id:-}" ]   && ARGS+=(--vnet-subnet-id "$aks_vnet_subnet_id")
[ -n "${aks_max_pods_per_node:-}" ] && ARGS+=(--max-pods "$aks_max_pods_per_node")

[ "${aks_private_cluster:-}" = "true" ] && ARGS+=(--enable-private-cluster)

if [ "${aks_autoscaling:-}" = "true" ]; then
    ARGS+=(--enable-cluster-autoscaler)
    [ -n "${aks_min_nodes:-}" ] && ARGS+=(--min-count "$aks_min_nodes")
    [ -n "${aks_max_nodes:-}" ] && ARGS+=(--max-count "$aks_max_nodes")
fi

echo "Creating AKS cluster: $aks_cluster_name"
RESULT=$(az aks create "${ARGS[@]}" --output json)
if [ $? -ne 0 ] || [ -z "$RESULT" ]; then
    echo "ERROR: failed to create AKS cluster"
    exit 1
fi

echo "AKS cluster is running"

# ---------------------------------------------------------------------------
# Retrieve kubeconfig and cluster endpoint
# ---------------------------------------------------------------------------
# Generate kubeconfig path if not provided
if [ -z "${kubeconfig:-}" ]; then
    SALT=$(md5sum <<<$RANDOM | head -c 10)
    kubeconfig="${VAULT}/kubeconfig-${SALT}"
fi

az aks get-credentials \
    --resource-group "$az_group_name" \
    --name "$aks_cluster_name" \
    --file "$kubeconfig" \
    --overwrite-existing

endpoint=$(jq -r '.fqdn // .privateFqdn // ""' <<< "$RESULT")

output "kubeconfig: $kubeconfig"
output "endpoint: https://$endpoint"
