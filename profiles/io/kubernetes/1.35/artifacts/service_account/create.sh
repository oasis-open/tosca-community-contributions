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
require_inputs kubeconfig metadata

# Build kubectl command (with optional context)
KUBECTL_CMD=$(build_kubectl_cmd "${kubeconfig}" "${context}")

# The optional automountServiceAccountToken input is a boolean. JSON
# requires that it is all lower case.
automountServiceAccountToken="${automountServiceAccountToken,,}"

# Generate a manifest using the optional values. Then create the
# service account.
jq -n \
  --argjson metadata "$metadata" \
  --argjson automountServiceAccountToken "${automountServiceAccountToken:-null}" \
  --argjson imagePullSecrets "${imagePullSecrets:-null}" \
  --argjson secrets "${secrets:-null}" \
  '{
    apiVersion: "v1",
    kind: "ServiceAccount",
    metadata: $metadata
  }
  | if $automountServiceAccountToken != null then .automountServiceAccountToken = $automountServiceAccountToken else . end
  | if $imagePullSecrets != null then .imagePullSecrets = $imagePullSecrets else . end
  | if $secrets != null then .secrets = $secrets else . end
  ' | $KUBECTL_CMD apply -f -

# Return details of the created resource
SERVICE_ACCOUNT_DETAILS=$(
jq -n \
  --argjson metadata "$metadata" \
  '{
    apiVersion: "v1",
    kind: "ServiceAccount",
    metadata: $metadata
  }
  ' | $KUBECTL_CMD get -f - -o json \
    | jq '.items[0]'
)

output "$SERVICE_ACCOUNT_DETAILS"
