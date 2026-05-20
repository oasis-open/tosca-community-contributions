#!/bin/bash

# Create a GKE cluster.
#
# Mandatory Environment Variables:
#
#     gcp_key_file
#     gcp_account
#     gcp_project
#     gcp_zone_name
#     gke_cluster_name
#     gke_node_count
#     vault
#
# Optional Environment Variables:
#
#     kubeconfig
#
#     gke_version
#     gke_machine_type
#     gke_disk_size
#     gke_disk_type
#     gke_image_type
#     gke_release_channel
#     gke_spot
#     gke_workload_identity
#     gke_dataplane_v2
#     gke_private_cluster
#     gke_network
#     gke_subnet
#     gke_max_pods_per_node
#     gke_autoscaling
#     gke_min_nodes
#     gke_max_nodes

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs gcp_project gcp_zone_name gke_cluster_name gke_node_count vault

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
    --project="$gcp_project"
    --zone="$gcp_zone_name"
    --num-nodes="$gke_node_count"
    --quiet
)

[ -n "${gke_version:-}" ]         && ARGS+=(--cluster-version="$gke_version")
[ -n "${gke_machine_type:-}" ]    && ARGS+=(--machine-type="$gke_machine_type")
[ -n "${gke_disk_size:-}" ]       && ARGS+=(--disk-size="$gke_disk_size")
[ -n "${gke_disk_type:-}" ]       && ARGS+=(--disk-type="$gke_disk_type")
[ -n "${gke_image_type:-}" ]      && ARGS+=(--image-type="$gke_image_type")
[ -n "${gke_release_channel:-}" ] && ARGS+=(--release-channel="$gke_release_channel")
[ -n "${gke_network:-}" ]         && ARGS+=(--network="$gke_network")
[ -n "${gke_subnet:-}" ]          && ARGS+=(--subnetwork="$gke_subnet")
[ -n "${gke_max_pods_per_node:-}" ] && ARGS+=(--default-max-pods-per-node="$gke_max_pods_per_node")

[ "${gke_spot:-}" = "true" ]               && ARGS+=(--spot)
[ "${gke_private_cluster:-}" = "true" ]    && ARGS+=(--enable-private-nodes --enable-private-endpoint)
[ "${gke_dataplane_v2:-}" = "true" ]       && ARGS+=(--enable-dataplane-v2)

if [ "${gke_workload_identity:-}" = "true" ]; then
    ARGS+=(--workload-pool="${gcp_project}.svc.id.goog")
fi

if [ "${gke_autoscaling:-}" = "true" ]; then
    ARGS+=(--enable-autoscaling)
    [ -n "${gke_min_nodes:-}" ] && ARGS+=(--min-nodes="$gke_min_nodes")
    [ -n "${gke_max_nodes:-}" ] && ARGS+=(--max-nodes="$gke_max_nodes")
fi

echo "Creating GKE cluster: $gke_cluster_name"
gcloud container clusters create "$gke_cluster_name" \
    "${ARGS[@]}" \
    --format=json
if [ $? -ne 0 ]; then
    echo "ERROR: failed to create GKE cluster"
    exit 1
fi

echo "GKE cluster is running"

# ---------------------------------------------------------------------------
# Retrieve cluster info and generate kubeconfig
# ---------------------------------------------------------------------------
CLUSTER_INFO=$(gcloud container clusters describe "$gke_cluster_name" \
    --project="$gcp_project" \
    --zone="$gcp_zone_name" \
    --format=json \
    --quiet)

endpoint=$(jq -r '.endpoint' <<< "$CLUSTER_INFO")
CA_DATA=$(jq -r '.masterAuth.clusterCaCertificate' <<< "$CLUSTER_INFO")

# Generate kubeconfig path if not provided
if [ -z "${kubeconfig:-}" ]; then
    SALT=$(md5sum <<<$RANDOM | head -c 10)
    kubeconfig="${VAULT}/kubeconfig-${SALT}"
fi

# Use gcloud to generate a proper kubeconfig
KUBECONFIG="$kubeconfig" gcloud container clusters get-credentials "$gke_cluster_name" \
    --project="$gcp_project" \
    --zone="$gcp_zone_name" \
    --quiet

output "kubeconfig: $kubeconfig"
output "endpoint: https://$endpoint"
