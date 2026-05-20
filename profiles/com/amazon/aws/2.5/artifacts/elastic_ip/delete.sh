#!/bin/bash

# This script expects the following environment variables:
#
#          aws_credentials_file
#          aws_region_name
#          aws_elastic_ip_id
#
# Optional environment variables:
#
#          aws_profile

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs aws_region_name aws_elastic_ip_id

aws ec2 release-address \
    --region        "$aws_region_name" \
    --allocation-id "$aws_elastic_ip_id"
