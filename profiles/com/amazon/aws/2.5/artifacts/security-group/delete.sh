#!/bin/bash

# This script expects the following environment variables:
#
#          aws_credentials_file
#          aws_region_name
#          aws_group_id
#
# Optional environment variables:
#
#          aws_profile

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs aws_region_name aws_group_id

REGION_ARGS=(--region "$aws_region_name")

# Delete the Security Group.
aws ec2 delete-security-group \
    "${REGION_ARGS[@]}" --group-id "$aws_group_id"
