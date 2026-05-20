#!/bin/bash

# Create an EKS cluster (control plane only).
#
# Mandatory Environment Variables:
#
#     aws_credentials_file
#     aws_region_name
#     eks_cluster_name
#     eks_cluster_role_arn
#
# Optional Environment Variables:
#
#     aws_profile
#     eks_version
#     eks_endpoint_public_access
#     eks_endpoint_private_access
#     eks_service_ipv4_cidr
#     eks_subnet_ids
#     eks_security_group_id

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs aws_region_name eks_cluster_name eks_cluster_role_arn

# ---------------------------------------------------------------------------
# Resolve subnet IDs: use provided subnets or discover default VPC subnets
# ---------------------------------------------------------------------------
if [ -n "${eks_subnet_ids:-}" ]; then
    SUBNET_CSV=$(jq -r 'if type == "array" then join(",") else . end' <<< "$eks_subnet_ids")
else
    echo "No subnets specified, discovering default VPC subnets..."
    DEFAULT_VPC=$(aws ec2 describe-vpcs \
        --region "$aws_region_name" \
        --filters Name=is-default,Values=true \
        --query 'Vpcs[0].VpcId' --output text)
    if [ -z "$DEFAULT_VPC" ] || [ "$DEFAULT_VPC" = "None" ]; then
        echo "ERROR: no subnets specified and no default VPC found in $aws_region_name"
        exit 1
    fi
    SUBNET_CSV=$(aws ec2 describe-subnets \
        --region "$aws_region_name" \
        --filters Name=vpc-id,Values="$DEFAULT_VPC" \
        --query 'Subnets[].SubnetId' --output text | tr '\t' ',')
    echo "Using default VPC subnets: $SUBNET_CSV"
fi

# ---------------------------------------------------------------------------
# Build and run the create-cluster command
# ---------------------------------------------------------------------------
CLUSTER_ARGS=(
    --region "$aws_region_name"
    --name "$eks_cluster_name"
    --role-arn "$eks_cluster_role_arn"
)

[ -n "${eks_version:-}" ] && CLUSTER_ARGS+=(--kubernetes-version "$eks_version")

# Build --resources-vpc-config value
VPC_CONFIG="subnetIds=$SUBNET_CSV"
if [ "${eks_endpoint_public_access:-}" = "false" ]; then
    VPC_CONFIG="$VPC_CONFIG,endpointPublicAccess=false"
fi
if [ "${eks_endpoint_private_access:-}" = "true" ]; then
    VPC_CONFIG="$VPC_CONFIG,endpointPrivateAccess=true"
fi
if [ -n "${eks_security_group_id:-}" ]; then
    VPC_CONFIG="$VPC_CONFIG,securityGroupIds=$eks_security_group_id"
fi
CLUSTER_ARGS+=(--resources-vpc-config "$VPC_CONFIG")

if [ -n "${eks_service_ipv4_cidr:-}" ]; then
    CLUSTER_ARGS+=(--kubernetes-network-config "serviceIpv4Cidr=$eks_service_ipv4_cidr")
fi

echo "Creating EKS cluster: $eks_cluster_name"
aws eks create-cluster "${CLUSTER_ARGS[@]}" --output json
if [ $? -ne 0 ]; then
    echo "ERROR: failed to create EKS cluster"
    exit 1
fi

# Wait for cluster to become ACTIVE
echo "Waiting for cluster to become active..."
aws eks wait cluster-active \
    --region "$aws_region_name" \
    --name "$eks_cluster_name"
if [ $? -ne 0 ]; then
    echo "ERROR: cluster did not become active"
    exit 1
fi

echo "Cluster is active"

# Output the resolved subnet IDs for use by the configure operation
output "subnet_ids: $SUBNET_CSV"
