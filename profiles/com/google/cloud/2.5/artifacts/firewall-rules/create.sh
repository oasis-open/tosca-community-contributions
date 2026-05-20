#!/bin/bash

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

# This script expects the following environment variables:
#
#    gcp_key_file
#    gcp_key_file
#    gcp_account
#    gcp_project
#    gcp_vpc_name
#
# Not Required Environment Variables:
#
#    gcp_region_name
#    gcp_ingress_rules
#    gcp_egress_rules

# First, add each ingress rule
for rule in $(jq -c '.[]' <<< "$gcp_ingress_rules");
do
    RULE_NAME=$(jq -r '.name' <<< "$rule")
    RULE_ARGS=$(jq -r '. | .protocol + ":" + (.port|tostring)' <<< "$rule")
    RULE_RANGE=$(jq -r '.cidr' <<< "$rule")

    echo $RULE_NAME >> /tmp/gcp.log
    echo $RULE_ARGS >> /tmp/gcp.log
    echo $RULE_RANGE >> /tmp/gcp.log
    gcloud compute firewall-rules create "$RULE_NAME" \
    --project="$gcp_project" \
    --account="$gcp_account" \
    --network "$gcp_vpc_name" \
    --action allow \
    --direction ingress \
    --rules "$RULE_ARGS" \
    --source-ranges "$RULE_RANGE" >> /tmp/gcp.log 2>&1
done

# Then, add each egress rule
for rule in $(jq -c '.[]' <<< "$gcp_egress_rules");
do
    RULE_NAME=$(jq -r '.name' <<< "$rule")
    RULE_ARGS=$(jq -r '. | .protocol + ":" + (.port|tostring)' <<< "$rule")
    RULE_RANGE=$(jq -r '.cidr' <<< "$rule")

    echo $RULE_NAME >> /tmp/gcp.log
    echo $RULE_ARGS >> /tmp/gcp.log
    echo $RULE_RANGE >> /tmp/gcp.log
    gcloud compute firewall-rules create "$RULE_NAME" \
    --project="$gcp_project" \
    --account="$gcp_account" \
    --network "$gcp_vpc_name" \
    --action allow \
    --direction egress \
    --rules "$RULE_ARGS" \
    --destination-ranges "$RULE_RANGE" >> /tmp/gcp.log 2>&1
done
