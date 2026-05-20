#!/bin/bash

# This script expects the following environment variables:
#
#          aws_credentials_file
#          aws_region_name
#
# Optional environment variables:
#
#          aws_profile

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs aws_region_name

RESULT=$(aws ec2 allocate-address \
	     --region "$aws_region_name" \
	     --domain vpc \
	     --output json)
if [ $? -ne 0 ] || [ -z "$RESULT" ]; then
    echo "ERROR: failed to allocate elastic IP"
    exit 1
fi

ip_address=$(jq -r '.PublicIp' <<< "$RESULT")
elastic_ip_id=$(jq -r '.AllocationId' <<< "$RESULT")

output "ip_address: $ip_address"
output "elastic_ip_id: $elastic_ip_id"
