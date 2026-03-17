#!/bin/bash
#
# Script to create a Kubernetes deployment

set -e  # Exit on error

# Import definitions from common library
HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
source $HERE/../common_lib.sh

# Define output function
init_output

# Make sure mandatory input values are present
require_inputs kubeconfig metadata spec

# Build kubectl command (with optional context)
KUBECTL_CMD=$(build_kubectl_cmd "${kubeconfig}" "${context}")

# Generate a manifest and create the deployment.
jq -n \
  --argjson metadata "$metadata" \
  --argjson spec "$spec" \
  '{
    apiVersion: "apps/v1",
    kind: "Deployment",
    spec: $spec,
    metadata: $metadata
  }
  ' | $KUBECTL_CMD apply -f -

# Return details of the created resource
DEPLOYMENT_DETAILS=$(
jq -n \
  --argjson metadata "$metadata" \
  '{
    apiVersion: "apps/v1",
    kind: "Deployment",
    metadata: $metadata
  }
  ' | $KUBECTL_CMD get -f - -o json \
    | jq '.items[0]'
)

output "$DEPLOYMENT_DETAILS"
