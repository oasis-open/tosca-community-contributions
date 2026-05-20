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

# Attach the Internet Gateway to a VPC
aws ec2 attach-internet-gateway \
    --region              "$aws_region_name" \
    --vpc-id              "$aws_vpc_id" \
    --internet-gateway-id "$aws_igw_id"
