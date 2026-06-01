#!/bin/bash

# This script expects the following environment variables:
#
#          aws_credentials_file
#          aws_region_name
#          aws_subnet_id
#
# Optional environment variables:
#
#          aws_profile

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs aws_region_name aws_subnet_id

# Delete the Subnet.
aws ec2 delete-subnet \
    --region    "$aws_region_name" \
    --subnet-id "$aws_subnet_id"
