#!/bin/bash

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

# This script expects the following environment variables:
#
#    gcp_key_file
#    gcp_key_file
#    gcp_account
#    gcp_project
#    gcp_zone_name
#    gcp_server_name

gcloud compute instances delete $gcp_server_name \
       --quiet \
       --zone=$gcp_zone_name \
       --project=$gcp_project \
       --account=$gcp_account  &> /tmp/gcp.log
