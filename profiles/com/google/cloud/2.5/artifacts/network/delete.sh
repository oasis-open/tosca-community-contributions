#!/bin/bash

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

# This script expects the following environment variables:
#
#    gcp_key_file
#    gcp_key_file
#    gcp_account
#    gcp_project
#    gcp_region_name
#    gcp_network_name

gcloud compute networks delete "$gcp_network_name" \
       --quiet \
       --project="$gcp_project" \
       --account="$gcp_account"  >> /tmp/gcp.log 2>&1
