#!/bin/bash

# This script expects the following Environment Variables:
#
#          aws_credentials_file
#          aws_region_name
#          aws_vpc_name
#          aws_cidr_block
#
# Optional environment variables:
#
#          aws_profile

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs aws_region_name aws_vpc_name aws_cidr_block

# Make sure no VPCs with that name already exists.
num_vpcs=$(aws ec2 describe-vpcs \
	       --region "$aws_region_name" \
	       --filters "Name=tag:Name,Values=$aws_vpc_name" 2>&1 | jq '.Vpcs | length')
if [ $? -ne 0 ] || [ -z "$num_vpcs" ]; then
    echo "ERROR: failed to query existing VPCs"
    exit 1
fi
if (( num_vpcs > 0 )); then
    echo "VPC with name \"$aws_vpc_name\" already exists in region \"$aws_region_name\""
    exit 11
fi

# Create the Virtual Private Cloud
RESULT=$(aws ec2 create-vpc \
	     --region "$aws_region_name" \
	     --cidr-block "$aws_cidr_block" \
	     --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=\"${aws_vpc_name}\"}]" \
             --output json)
if [ $? -ne 0 ] || [ -z "$RESULT" ]; then
    echo "ERROR: failed to create VPC"
    exit 1
fi

vpc_id=$(jq -r '.Vpc.VpcId' <<< "$RESULT")
output "vpc_id: $vpc_id"
