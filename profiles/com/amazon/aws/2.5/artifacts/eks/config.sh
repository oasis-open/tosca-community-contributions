#!/bin/bash

# Create the managed node group and retrieve kubeconfig for an EKS cluster.
#
# Mandatory Environment Variables:
#
#     aws_credentials_file
#     aws_region_name
#     eks_cluster_name
#     eks_node_count
#     eks_node_role_arn
#     eks_subnet_ids
#     vault
#
# Optional Environment Variables:
#
#     aws_profile
#     kubeconfig
#     eks_instance_type
#     eks_disk_size
#     eks_ami_type
#     eks_capacity_type
#     eks_max_pods_per_node
#     eks_autoscaling
#     eks_min_nodes
#     eks_max_nodes

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs aws_region_name eks_cluster_name eks_node_count \
               eks_node_role_arn eks_subnet_ids vault

VAULT=$(expand_path "$vault")

# Make sure vault exists
if [ ! -d "${VAULT}" ]; then
    sudo mkdir -p "${VAULT}"
    USER_NAME=$(id -un)
    GROUP_NAME=$(id -gn)
    sudo chown ${USER_NAME}.${GROUP_NAME} "${VAULT}"
fi

# ---------------------------------------------------------------------------
# Create the managed node group
# ---------------------------------------------------------------------------
NODEGROUP_NAME="${eks_cluster_name}-nodes"

NODEGROUP_ARGS=(
    --region "$aws_region_name"
    --cluster-name "$eks_cluster_name"
    --nodegroup-name "$NODEGROUP_NAME"
    --node-role "$eks_node_role_arn"
    --scaling-config "minSize=${eks_min_nodes:-$eks_node_count},maxSize=${eks_max_nodes:-$eks_node_count},desiredSize=$eks_node_count"
)

[ -n "${eks_instance_type:-}" ] && NODEGROUP_ARGS+=(--instance-types "$eks_instance_type")
[ -n "${eks_disk_size:-}" ]     && NODEGROUP_ARGS+=(--disk-size "$eks_disk_size")
[ -n "${eks_ami_type:-}" ]      && NODEGROUP_ARGS+=(--ami-type "$eks_ami_type")
[ -n "${eks_capacity_type:-}" ] && NODEGROUP_ARGS+=(--capacity-type "$eks_capacity_type")
[ -n "${eks_max_pods_per_node:-}" ] && NODEGROUP_ARGS+=(--max-pods-per-node "$eks_max_pods_per_node")

# eks_subnet_ids is a comma-separated string from the create output
NODEGROUP_ARGS+=(--subnets $(echo "$eks_subnet_ids" | tr ',' ' '))

echo "Creating node group: $NODEGROUP_NAME"
aws eks create-nodegroup "${NODEGROUP_ARGS[@]}" --output json
if [ $? -ne 0 ]; then
    echo "ERROR: failed to create node group"
    exit 1
fi

echo "Waiting for node group to become active..."
aws eks wait nodegroup-active \
    --region "$aws_region_name" \
    --cluster-name "$eks_cluster_name" \
    --nodegroup-name "$NODEGROUP_NAME"
if [ $? -ne 0 ]; then
    echo "ERROR: node group did not become active"
    exit 1
fi

echo "Node group is active"

# ---------------------------------------------------------------------------
# Retrieve cluster info and generate kubeconfig
# ---------------------------------------------------------------------------
CLUSTER_INFO=$(aws eks describe-cluster \
    --region "$aws_region_name" \
    --name "$eks_cluster_name" \
    --output json \
    --query 'cluster')

endpoint=$(jq -r '.endpoint' <<< "$CLUSTER_INFO")
CA_DATA=$(jq -r '.certificateAuthority.data' <<< "$CLUSTER_INFO")

# Generate kubeconfig path if not provided
if [ -z "${kubeconfig:-}" ]; then
    SALT=$(md5sum <<<$RANDOM | head -c 10)
    kubeconfig="${VAULT}/kubeconfig-${SALT}"
fi

cat > "$kubeconfig" <<EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    server: ${endpoint}
    certificate-authority-data: ${CA_DATA}
  name: ${eks_cluster_name}
contexts:
- context:
    cluster: ${eks_cluster_name}
    user: ${eks_cluster_name}
  name: ${eks_cluster_name}
current-context: ${eks_cluster_name}
users:
- name: ${eks_cluster_name}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: aws
      args:
        - eks
        - get-token
        - --region
        - ${aws_region_name}
        - --cluster-name
        - ${eks_cluster_name}
      env:
        - name: AWS_SHARED_CREDENTIALS_FILE
          value: ${aws_credentials_file}
        - name: AWS_PROFILE
          value: ${aws_profile:-default}
EOF

output "kubeconfig: $kubeconfig"
output "endpoint: $endpoint"
