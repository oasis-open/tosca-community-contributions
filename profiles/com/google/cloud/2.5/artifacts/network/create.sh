#!/bin/bash

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

# This script expects the following environment variables:
#
#    gcp_key_file
#    gcp_key_file
#    gcp_account
#    gcp_project
#    gcp_network_name

NETWORK_ID=$(gcloud compute networks create "$gcp_network_name" \
       --quiet \
       --format="value(id)" \
       --project="$gcp_project" \
       --account="$gcp_account" \
       --subnet-mode=custom \
       --bgp-routing-mode=regional >> /tmp/gcp.log 2>&1)

echo network_id: $NETWORK_ID


