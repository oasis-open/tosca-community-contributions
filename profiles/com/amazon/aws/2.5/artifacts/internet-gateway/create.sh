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

# Create an Internet Gateway
RESULT=$(aws ec2 create-internet-gateway \
	     --region "$aws_region_name" \
	     --output json)
if [ $? -ne 0 ] || [ -z "$RESULT" ]; then
    echo "ERROR: failed to create internet gateway"
    exit 1
fi

aws_igw_id=$(jq -r '.InternetGateway.InternetGatewayId' <<< "$RESULT")
output "aws_igw_id: $aws_igw_id"
