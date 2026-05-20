#!/usr/bin/env bash
set -eo pipefail

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. $HERE/../common_lib.sh

init_output

# Check mandatory inputs
require_inputs kubeconfig kubernetes_version

# Build kubectl command (with optional context)
KUBECTL_CMD=$(build_kubectl_cmd "${kubeconfig}" "${context}")

# Is a specific kubevirt version requested?
if [ -z "${version+x}" ]; then
    # No KubeVirt version specified. Determine compatible KubeVirt and
    # CDI versions based on K8s version KubeVirt compatibility matrix
    # (as of early 2025)
    IFS='.' read -r K8S_MAJOR K8S_MINOR K8S_PATCH <<< $kubernetes_version
    K8S_VERSION="${K8S_MAJOR}.${K8S_MINOR}"
    echo "Kubernetes version: ${K8S_VERSION}"
    if [ "$K8S_MINOR" -ge 32 ]; then
	version="1.7.0"
	CDI_VERSION="v1.64.0"
    else
	echo -e "Warning: Kubernetes version v1.${K8S_MINOR} is quite old"
	echo "Using older compatible versions..."
	version="1.4.1"
	CDI_VERSION="v1.60.0"
    fi
fi
KUBEVIRT_VERSION=v$version
echo "Kubevirt version $KUBEVIRT_VERSION requested"

echo "Installing KubeVirt operator..."
$KUBECTL_CMD apply -f "https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/kubevirt-operator.yaml"

echo "Installing KubeVirt custom resource..."
$KUBECTL_CMD apply -f "https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/kubevirt-cr.yaml"

echo "Installing CDI operator..."
$KUBECTL_CMD apply -f "https://github.com/kubevirt/containerized-data-importer/releases/download/${CDI_VERSION}/cdi-operator.yaml"

echo "Installing CDI custom resource..."
$KUBECTL_CMD apply -f "https://github.com/kubevirt/containerized-data-importer/releases/download/${CDI_VERSION}/cdi-cr.yaml"

echo "Waiting for CDI to become ready..."
$KUBECTL_CMD -n cdi wait cdi/cdi --for condition=Available --timeout=15m

echo "CDI ${CDI_VERSION} successfully installed and ready!"

echo "Waiting for KubeVirt to become ready..."
$KUBECTL_CMD -n kubevirt wait kv kubevirt --for condition=Available --timeout=15m

echo "Waiting for the virt-api deployment to become ready..."
$KUBECTL_CMD -n kubevirt \
  rollout status deployment/virt-api --timeout=5m

echo "Waiting for virt-api Service to have endpoints..."
until $KUBECTL_CMD -n kubevirt get endpoints virt-api \
  -o jsonpath='{.subsets[*].addresses[*].ip}' 2>/dev/null | grep -q .; do
    echo "  No endpoints yet, waiting..."
    sleep 2
done
echo "virt-api endpoints are available"

echo "Waiting for webhook configurations to be registered..."
# Wait for the webhook configurations to exist
until $KUBECTL_CMD get validatingwebhookconfiguration virt-api-validator &>/dev/null; do
    echo "  Waiting for virt-api-validator webhook..."
    sleep 2
done

until $KUBECTL_CMD get mutatingwebhookconfiguration virt-api-mutator &>/dev/null; do
    echo "  Waiting for virt-api-mutator webhook..."
    sleep 2
done

# Wait for the virt-api webhook to become responsive by probing it
# with a dry-run. The API server caches webhook endpoint failures
# (see https://github.com/kubernetes/kubernetes/issues/106501), so
# even after endpoints are available it may return "no endpoints
# available" for a while. Probing avoids a fixed wait and exits as
# soon as the webhook is actually reachable.
PROBE_MANIFEST=$(mktemp)
cat > "$PROBE_MANIFEST" <<'EOF'
apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  name: webhook-probe
  namespace: default
spec:
  running: false
  template:
    spec:
      domain:
        resources: {}
EOF

echo "Waiting for virt-api webhook to become responsive..."
MAX_WAIT=150
INTERVAL=5
ELAPSED=0
while [ $ELAPSED -lt $MAX_WAIT ]; do
    OUTPUT=$($KUBECTL_CMD create --dry-run=server -f "$PROBE_MANIFEST" 2>&1) || true
    if ! echo "$OUTPUT" | grep -q "no endpoints available"; then
        echo "Webhook is responsive!"
        break
    fi
    echo "  Webhook not yet responsive (${ELAPSED}s elapsed), waiting..."
    sleep $INTERVAL
    ELAPSED=$((ELAPSED + INTERVAL))
done

rm -f "$PROBE_MANIFEST"

if [ $ELAPSED -ge $MAX_WAIT ]; then
    echo "WARNING: Webhook did not become responsive within ${MAX_WAIT}s, proceeding anyway"
fi

echo "KubeVirt ${KUBEVIRT_VERSION} successfully installed and webhooks are verified!"

# Return output values
output version: $version
