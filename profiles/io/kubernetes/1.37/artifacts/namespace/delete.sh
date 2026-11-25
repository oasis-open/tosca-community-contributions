#!/bin/bash
#
# Script to delete a Kubernetes cluster-scoped resource

set -e  # Exit on error

# Import definitions from common library
HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
source $HERE/../common_lib.sh

# Define output function
init_output

# Make sure mandatory input values are present
require_inputs kubeconfig metadata

# Build kubectl command (with optional context)
KUBECTL_CMD=$(build_kubectl_cmd "${kubeconfig}" "${context}")

# Generate the manifest and delete the resource.
jq -n \
  --argjson metadata "$metadata" \
  '{
    apiVersion: "v1",
    kind: "Namespace",
    metadata: $metadata
  }
  ' | $KUBECTL_CMD delete -f -
