#!/bin/bash

# This script expects the following environment variables:
#
#          aws_credentials_file
#          aws_region_name
#          aws_key_id
#          key_file
#
# Optional environment variables:
#
#          aws_profile

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs aws_region_name aws_key_id key_file

# Delete the Key Pair
aws ec2 delete-key-pair \
    --region      "$aws_region_name" \
    --key-pair-id "$aws_key_id"

# Delete the key files from the credential vault
rm -f "${key_file}" "${key_file}.pub"
