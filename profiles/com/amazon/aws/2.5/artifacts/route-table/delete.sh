#!/bin/bash

# This script expects the following environment variables:
#
#          aws_credentials_file
#          aws_region_name
#          aws_route_table_id
#
# Optional environment variables:
#
#          aws_profile

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs aws_region_name aws_route_table_id

# Delete the Route Table
aws ec2 delete-route-table \
    --region         "$aws_region_name" \
    --route-table-id "$aws_route_table_id"
