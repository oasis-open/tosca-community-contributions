#!/bin/bash

# Delete an AKS cluster.
#
# Mandatory Environment Variables:
#
#     az_credentials_file
#     az_group_name
#     aks_cluster_name

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs az_credentials_file az_group_name aks_cluster_name

echo "Deleting AKS cluster: $aks_cluster_name"
az aks delete \
    --yes \
    --resource-group "$az_group_name" \
    --name "$aks_cluster_name"

# Clean up kubeconfig
rm -f ~/.kube/aks-${aks_cluster_name}.kubeconfig

echo "AKS cluster deleted"
