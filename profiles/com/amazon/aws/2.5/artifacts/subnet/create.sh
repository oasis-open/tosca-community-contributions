#!/bin/bash

# This script expects the following environment variables:
#
#          aws_credentials_file
#          aws_region_name
#          aws_cidr_block
#          aws_vpc_id
#
# Optional environment variables:
#
#          aws_map_public_ip
#          aws_route_table_id
#          aws_profile

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs aws_region_name aws_cidr_block aws_vpc_id

# Create a Subnet on a Virtual Private Cloud
RESULT=$(aws ec2 create-subnet \
	     --region     "$aws_region_name" \
	     --vpc-id     "$aws_vpc_id" \
	     --cidr-block "$aws_cidr_block" \
	     --output json)
if [ $? -ne 0 ] || [ -z "$RESULT" ]; then
    echo "ERROR: failed to create subnet"
    exit 1
fi

SUBNET_ID=$(jq -r '.Subnet.SubnetId' <<< "$RESULT")

if [ -n "${aws_map_public_ip}" ]; then
    if [ "${aws_map_public_ip}" == 'True' ]; then
	AWS_MODIFY_SUBNET_ARGS=(--map-public-ip-on-launch)
    else
	AWS_MODIFY_SUBNET_ARGS=(--no-map-public-ip-on-launch)
    fi
    aws ec2 modify-subnet-attribute \
	--region    "$aws_region_name" \
	--subnet-id "$SUBNET_ID" "${AWS_MODIFY_SUBNET_ARGS[@]}"
fi

if [ -n "${aws_route_table_id}" ]; then
    aws ec2 associate-route-table \
	--region         "$aws_region_name" \
	--route-table-id "$aws_route_table_id" \
	--subnet-id      "$SUBNET_ID"
fi

output "subnet_id: $SUBNET_ID"
