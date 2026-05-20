#!/bin/bash

# This script expects the following environment variables:
#
#          aws_credentials_file
#          aws_region_name
#          aws_instance_id
#
# Optional environment variables:
#
#          aws_profile

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs aws_region_name aws_instance_id

# Terminate the Instance.
aws ec2 terminate-instances \
    --region      "$aws_region_name" \
    --instance-id "$aws_instance_id"
