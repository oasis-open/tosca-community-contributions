#!/bin/bash
#
# Script to create a Kubernetes namespace

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

# Generate a manifest using the optional spec. Then create the
# namespace.
jq -n \
  --argjson metadata "$metadata" \
  --argjson spec "$spec" \
  '{
    apiVersion: "v1",
    kind: "Pod",
    spec: $spec,
    metadata: $metadata
  }
  ' | $KUBECTL_CMD apply -f -

# Return details of the created resource
POD_DETAILS=$(
jq -n \
  --argjson metadata "$metadata" \
  '{
    apiVersion: "v1",
    kind: "Pod",
    metadata: $metadata
  }
  ' | $KUBECTL_CMD get -f - -o json \
    | jq '.items[0]'
)

output "$POD_DETAILS"
