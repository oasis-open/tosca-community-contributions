#!/bin/bash

# Delete an EKS cluster and its managed node group.
#
# Mandatory Environment Variables:
#
#     aws_credentials_file
#     aws_region_name
#     eks_cluster_name

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs aws_region_name eks_cluster_name

NODEGROUP_NAME="${eks_cluster_name}-nodes"

# Delete the node group first
echo "Deleting node group: $NODEGROUP_NAME"
aws eks delete-nodegroup \
    --region "$aws_region_name" \
    --cluster-name "$eks_cluster_name" \
    --nodegroup-name "$NODEGROUP_NAME" \
    --output json 2>/dev/null

# Wait for node group deletion
echo "Waiting for node group deletion..."
aws eks wait nodegroup-deleted \
    --region "$aws_region_name" \
    --cluster-name "$eks_cluster_name" \
    --nodegroup-name "$NODEGROUP_NAME" 2>/dev/null

# Delete the cluster
echo "Deleting EKS cluster: $eks_cluster_name"
aws eks delete-cluster \
    --region "$aws_region_name" \
    --name "$eks_cluster_name" \
    --output json

# Wait for cluster deletion
echo "Waiting for cluster deletion..."
aws eks wait cluster-deleted \
    --region "$aws_region_name" \
    --name "$eks_cluster_name"

# Clean up kubeconfig
if [ -n "${kubeconfig:-}" ]; then
    rm -f "$(expand_path "$kubeconfig")"
fi

echo "EKS cluster deleted"
