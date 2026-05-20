#!/bin/bash

# Script to delete a KubeVirt VM

set -e

# Import definitions from common library
HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
source $HERE/../common_lib.sh

init_output

# Check mandatory inputs
require_inputs kubeconfig vm_name

# Build kubectl and virtctl commands (with optional context)
KUBECTL_CMD=$(build_kubectl_cmd "${kubeconfig}" "${context}")
VIRTCTL_CMD=$(build_kubectl_cmd "${kubeconfig}" "${context}" | sed 's|^kubectl |virtctl |')

# Get namespace
NAMESPACE="${namespace:-default}"

echo "Deleting KubeVirt VM: $vm_name in namespace: $NAMESPACE"

# Check if VM exists
echo "Checking if VM exists..."
if ! $KUBECTL_CMD get vm "$vm_name" -n "$NAMESPACE" &>>/dev/null; then
    echo "VM '$vm_name' not found in namespace '$NAMESPACE'"
    exit 1
fi

# Stop the VM first (graceful shutdown)
echo "Stopping VM..."
if $KUBECTL_CMD get vmi "$vm_name" -n "$NAMESPACE"; then
    $VIRTCTL_CMD stop "$vm_name" -n "$NAMESPACE" || true
    echo "Waiting for VM to stop..."
    sleep 5
fi

# Delete the VM
echo "Deleting VM '$vm_name'..."
$KUBECTL_CMD delete vm "$vm_name" -n "$NAMESPACE"
if [ $? -eq 0 ]; then
    echo "✓ VM '$vm_name' deleted successfully from namespace '$NAMESPACE'"
else
    echo "ERROR: Failed to delete VM."
    exit 1
fi

# Verify deletion
echo "Verifying deletion..."
if $KUBECTL_CMD get vm "$vm_name" -n "$NAMESPACE" &>>/dev/null; then
    echo "WARNING: VM still exists"
else
    echo "✓ VM deletion confirmed"
fi

# Check for any remaining pods
echo "Checking for remaining virt-launcher pods..."
PODS=$($KUBECTL_CMD get pods -n "$NAMESPACE" -l "kubevirt.io/vm=$vm_name" -o name 2>/dev/null || true)

if [ -n "$PODS" ]; then
    echo "Found remaining pods:"
    echo "$PODS"
    echo "Cleaning up pods..."
    $KUBECTL_CMD delete pods -n "$NAMESPACE" -l "kubevirt.io/vm=$vm_name" || true
else
    echo "✓ No remaining pods found"
fi

echo "Deletion complete!"
