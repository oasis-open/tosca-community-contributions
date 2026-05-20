#!/bin/bash

# Delete a GKE cluster.
#
# Mandatory Environment Variables:
#
#     gcp_key_file
#     gcp_account
#     gcp_project
#     gcp_zone_name
#     gke_cluster_name

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs gcp_project gcp_zone_name gke_cluster_name

echo "Deleting GKE cluster: $gke_cluster_name"
gcloud container clusters delete "$gke_cluster_name" \
    --project="$gcp_project" \
    --zone="$gcp_zone_name" \
    --quiet

# Clean up kubeconfig
rm -f ~/.kube/gke-${gke_cluster_name}.kubeconfig

echo "GKE cluster deleted"
