#!/bin/bash

# This script expects the following environment variables:
#
#          aws_credentials_file
#          aws_region_name
#          aws_interface_id
#          aws_elastic_ip_id
#
# Optional environment variables:
#
#          aws_profile

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs aws_region_name aws_interface_id aws_elastic_ip_id

RESULT=$(aws ec2 associate-address \
	     --region               "$aws_region_name" \
	     --allocation-id        "$aws_elastic_ip_id" \
	     --network-interface-id "$aws_interface_id" \
	     --output json)
if [ $? -ne 0 ] || [ -z "$RESULT" ]; then
    echo "ERROR: failed to associate address"
    exit 1
fi

association_id=$(jq -r '.AssociationId' <<< "$RESULT")
output "association_id: $association_id"
