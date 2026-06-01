#!/bin/bash

# Script to create an Ubuntu 22.04 VM on KubeVirt
set -e

# Import definitions from common library
HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
source $HERE/../common_lib.sh

# Define output function
init_output

# Make sure mandatory input values are present
require_inputs kubeconfig vm_name public_key_file

# Build kubectl command (with optional context)
KUBECTL_CMD=$(build_kubectl_cmd "${kubeconfig}" "${context}")

# Get namespace
NAMESPACE="${namespace:-default}"

SERVICE_NAME=${vm_name}-svc

echo "Creating Ubuntu 22.04 VM on KubeVirt"
echo "VM Name: $vm_name"
echo "Service Name: $SERVICE_NAME"
echo "Namespace: $NAMESPACE"
echo "Kubeconfig: $kubeconfig"

# Check if SSH key exists
SSH_KEY=""
if [ -f "$public_key_file" ]; then
    echo "SSH Key: $public_key_file"
    SSH_KEY=$(cat "$public_key_file")
else
    echo "Error: SSH key not found at $public_key_file"
    exit 1
fi

# Prepare cloud-init userData
CLOUD_INIT_USERDATA=$(cat <<'USERDATA'
#cloud-config
users:
  - name: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin
    home: /home/ubuntu
    shell: /bin/bash
    lock_passwd: false
    ssh_authorized_keys:
      - SSH_KEY_PLACEHOLDER
password: ubuntu
chpasswd: { expire: False }
ssh_pwauth: True
package_update: true
packages:
  - qemu-guest-agent
  - openssh-server
runcmd:
  - systemctl enable ssh
  - systemctl start ssh
USERDATA
)
# Replace placeholder with actual SSH key
CLOUD_INIT_USERDATA="${CLOUD_INIT_USERDATA//SSH_KEY_PLACEHOLDER/$SSH_KEY}"

# Create the VM
echo "Creating VM..."
cat <<EOF | $KUBECTL_CMD apply -f -
apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  name: ${vm_name}
  namespace: ${NAMESPACE}
spec:
  running: true
  # Embedded DataVolume (auto-creates the PVC with desired size)
  dataVolumeTemplates:
  - metadata:
      name: ${vm_name}-rootdisk
    spec:
      source:
        registry:
          url: docker://quay.io/containerdisks/ubuntu:22.04
      pvc:
        storageClassName: local-path
        accessModes:
          - ReadWriteOnce
        resources:
          requests:
            storage: 20Gi   # <-- adjust disk size here
  template:
    metadata:
      labels:
        kubevirt.io/vm: ${vm_name}
    spec:
      domain:
        cpu:
          cores: 1
        resources:
          requests:
            memory: 2Gi
        devices:
          disks:
          - name: rootdisk
            disk:
              bus: virtio
          - name: cloudinitdisk
            disk:
              bus: virtio
          interfaces:
          - name: default
            masquerade: {}
      networks:
      - name: default
        pod: {}
      volumes:
      - name: rootdisk
        dataVolume:
          name: ${vm_name}-rootdisk
      - name: cloudinitdisk
        cloudInitNoCloud:
          userData: |
$(echo "$CLOUD_INIT_USERDATA" | sed 's/^/            /')
EOF

if [ $? -eq 0 ]; then
    echo "✓ VM '$vm_name' created successfully in namespace '$NAMESPACE'"
else
    echo "ERROR: Failed to create VM."
    exit 1
fi

# Build the manifest for the node port service.
build_manifest() {
    # Start with base structure
    MANIFEST="apiVersion: v1
kind: Service
metadata:
  name: $SERVICE_NAME
  namespace: $NAMESPACE
spec:
  type: NodePort
  selector:
    kubevirt.io/vm: $vm_name
  ports:
  - protocol: TCP
    port: 22
    targetPort: 22"

    # Add nodePort if specified
    if [ -n "$node_port" ]; then
        MANIFEST="$MANIFEST
    nodePort: $node_port"
    fi

}
build_manifest

# Create the NodePort service using the manifest
echo "$MANIFEST" | $KUBECTL_CMD apply -f -
if [ $? -ne 0 ]; then
    echo "Failed to create NODE PORT service"
    exit 1
fi

echo "Waiting for NodePort service..."
$KUBECTL_CMD -n $NAMESPACE wait --for=jsonpath='{.spec.type}'=NodePort service/"$SERVICE_NAME" --timeout=60s || exit_code=$?
if [[ -z "${exit_code:-}" ]]; then
  # Command succeeded (exit_code not set)
  echo "Node port service is ready"
elif [[ $exit_code -eq 1 ]]; then
  echo "✗ ERROR: Service not ready within timeout" >&2
  $KUBECTL_CMD -n $NAMESPACE get service "$SERVICE_NAME" || echo "Service not found"
  exit 1
else
  echo "ERROR: kubectl wait failed (exit code: $exit_code)" >&2
  exit $exit_code
fi

# Extract and validate node port
NODE_PORT=$($KUBECTL_CMD -n $NAMESPACE get service "$SERVICE_NAME" -o jsonpath='{.spec.ports[0].nodePort}')
if [[ -z "$NODE_PORT" || "$NODE_PORT" == "null" ]]; then
  echo "✗ ERROR: NodePort not allocated" >&2
  $KUBECTL_CMD -n $NAMESPACE get service "$SERVICE_NAME" -o yaml
  exit 1
fi

echo "Waiting for VM to start..."
for i in {1..60}; do
    if $KUBECTL_CMD get vmi "$vm_name" -n "$NAMESPACE" &>> /dev/null; then
        echo "✓ VM is running"
        break
    fi
    if [ $i -eq 60 ]; then
        echo "WARNING: VM did not start within 60 seconds"
        echo "Check status with: $KUBECTL_CMD get vm $vm_name -n $NAMESPACE"
        exit 1
    fi
    sleep 2
    echo -n "."
done

# Wait for VM to be ready
echo "Waiting for VM to be ready..."
TIMEOUT="5m"
$KUBECTL_CMD -n $NAMESPACE wait --for=condition=Ready vmi/"$vm_name" --timeout="$TIMEOUT" || exit_code=$?
if [[ -z "${exit_code:-}" ]]; then
  # Command succeeded (exit_code not set)
  echo "VM is ready"
elif [[ $exit_code -eq 1 ]]; then
  echo "ERROR: Timeout waiting for VM" >&2
  $KUBECTL_CMD -n $NAMESPACE describe vmi "$vm_name"
  exit 1
else
  echo "ERROR: kubectl wait failed (exit code: $exit_code)" >&2
  exit $exit_code
fi

# Get node IP for complete connection info
NODE_NAME=$($KUBECTL_CMD get vmi "$vm_name" -n "$NAMESPACE" -o jsonpath='{.status.nodeName}' 2>/dev/null)
if [ -z "$NODE_NAME" ]; then
    echo "Error: Could not find running VM instance '$vm_name' in namespace '$NAMESPACE'"
    echo "Make sure the VM is running (not just defined)"
    exit 1
fi

echo "VM is running on node: $NODE_NAME"
# Get the node's IP address (InternalIP)
NODE_IP=$($KUBECTL_CMD get node "$NODE_NAME" -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}')
if [ -z "$NODE_IP" ]; then
    echo "Error: Could not retrieve IP address for node '$NODE_NAME'"
    exit 1
fi

echo "VM Status:"
$KUBECTL_CMD get vm "$vm_name" -n "$NAMESPACE"
$KUBECTL_CMD get vmi "$vm_name" -n "$NAMESPACE" || true

# Return output values
output node_port: $NODE_PORT
output public_address: $NODE_IP
