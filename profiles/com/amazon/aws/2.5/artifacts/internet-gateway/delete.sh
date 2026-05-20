#!/bin/bash

# This script expects the following environment variables:
#
#          aws_credentials_file
#          aws_region_name
#          aws_vpc_id
#          aws_igw_id
#
# Optional environment variables:
#
#          aws_profile

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs aws_region_name aws_vpc_id aws_igw_id

# Detach from the VPC
aws ec2 detach-internet-gateway \
    --region              "$aws_region_name" \
    --vpc-id              "$aws_vpc_id" \
    --internet-gateway-id "$aws_igw_id"

# Delete the internet gateway
aws ec2 delete-internet-gateway \
    --region              "$aws_region_name" \
    --internet-gateway-id "$aws_igw_id"
