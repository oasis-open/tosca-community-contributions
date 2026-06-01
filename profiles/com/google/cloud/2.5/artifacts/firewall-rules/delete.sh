#!/bin/bash

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

# This script expects the following environment variables:
#
#    gcp_key_file
#    gcp_key_file
#    gcp_account
#    gcp_project
#
# Not Required Environment Variables:
#
#    gcp_region_name
#    gcp_ingress_rules
#    gcp_egress_rules

echo DELETE $gcp_ingress_rules >> /tmp/gcp.log

# First, delete each ingress rule
for rule in $(jq -c '.[]' <<< "$gcp_ingress_rules");
do
    RULE_NAME=$(jq -r '.name' <<< "$rule")
    echo $RULE_NAME >> /tmp/gcp.log
    gcloud compute firewall-rules delete "$RULE_NAME" \
	   --quiet \
	   --project="$gcp_project" \
	   --account="$gcp_account"  >> /tmp/gcp.log 2>&1
done

# Then, delete each egress rule
for rule in $(jq -c '.[]' <<< "$gcp_egress_rules");
do
    RULE_NAME=$(jq -r '.name' <<< "$rule")
    echo $RULE_NAME >> /tmp/gcp.log
    gcloud compute firewall-rules delete "$RULE_NAME" \
	   --quiet \
	   --project="$gcp_project" \
	   --account="$gcp_account"  >> /tmp/gcp.log 2>&1
done
