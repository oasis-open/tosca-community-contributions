#!/bin/bash

# This script expects the following environment variables:
#
#          aws_credentials_file
#          aws_region_name
#          aws_vpc_id
#
# Optional environment variables:
#
#          aws_profile

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs aws_region_name aws_vpc_id

# Delete the Virtual Private Cloud
aws ec2 delete-vpc \
    --region  "$aws_region_name" \
    --vpc-id  "$aws_vpc_id"
