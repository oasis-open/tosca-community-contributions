#!/usr/bin/env bash
set -eo pipefail

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. $HERE/../common_lib.sh

init_output

# Check mandatory inputs
require_inputs kubeconfig version

# Build kubectl command (with optional context)
KUBECTL_CMD=$(build_kubectl_cmd "${kubeconfig}" "${context}")

echo "Starting KubeVirt uninstall (release: $version)"

# 1. Delete VMs and VMIs only if CRDs exist
for CRD in virtualmachines.kubevirt.io virtualmachineinstances.kubevirt.io; do
  if $KUBECTL_CMD get crd "$CRD" &>/dev/null; then
    # Determine resource type
    if [ "$CRD" = "virtualmachines.kubevirt.io" ]; then
      RESOURCE="vm"
    else
      RESOURCE="vmi"
    fi

    echo "Deleting all $RESOURCE resources..."
    $KUBECTL_CMD delete "$RESOURCE" --all --all-namespaces --ignore-not-found
  else
    echo "CRD $CRD not found, skipping resource deletion"
  fi
done

# 2. Delete KubeVirt Custom Resource
echo "Deleting KubeVirt CR..."
$KUBECTL_CMD delete -f "https://github.com/kubevirt/kubevirt/releases/download/v${version}/kubevirt-cr.yaml" --ignore-not-found

# 3. Delete KubeVirt Operator
echo "Deleting KubeVirt operator..."
$KUBECTL_CMD delete -f "https://github.com/kubevirt/kubevirt/releases/download/v${version}/kubevirt-operator.yaml" --ignore-not-found

# 4. Delete kubevirt namespace
echo "Deleting kubevirt namespace..."
$KUBECTL_CMD delete namespace kubevirt --ignore-not-found

# 5. Delete hostpath storage class (for k3s/local-path)
echo "Deleting hostpath storage class if it exists..."
$KUBECTL_CMD delete sc hostpath --ignore-not-found

# 6. Delete all KubeVirt CRDs
CRDS=(
  kubevirts.kubevirt.io
  virtualmachines.kubevirt.io
  virtualmachineinstances.kubevirt.io
  virtualmachineinstancepresets.kubevirt.io
  virtualmachineinstancereplicasets.kubevirt.io
  virtualmachineinstancemigrations.kubevirt.io
  migratablevirtualmachines.kubevirt.io
)
for crd in "${CRDS[@]}"; do
  echo "Deleting CRD $crd..."
  $KUBECTL_CMD delete crd "$crd" --ignore-not-found
done

echo "KubeVirt uninstall complete!"
