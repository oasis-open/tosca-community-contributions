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
#    gcp_subnet_name
#    gcp_cidr_block
#    gcp_vpc_name

SUBNET_ID=$(gcloud compute networks subnets create "$gcp_subnet_name" \
       --quiet \
       --format="value(id)" \
       --project="$gcp_project" \
       --account="$gcp_account" \
       --network="$gcp_vpc_name" \
       --region="$gcp_region_name" \
       --range="$gcp_cidr_block"  >> /tmp/gcp.log 2>&1)

echo subnet_id: $SUBNET_ID
