#!/bin/bash

# This script expects the following environment variables:
#
#          aws_credentials_file
#          aws_region_name
#          key_name
#          public_key_file
#
# Optional environment variables:
#
#          aws_profile

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs aws_region_name key_name public_key_file

# Import the public key to AWS.
KEYPAIR=$(aws ec2 import-key-pair \
              --region              "$aws_region_name" \
              --key-name            "$key_name" \
              --public-key-material "fileb://${public_key_file}" \
              --output json)
if [ $? -ne 0 ] || [ -z "$KEYPAIR" ]; then
    echo "ERROR: failed to import key pair"
    exit 1
fi
echo "$KEYPAIR"

key_id=$(jq -r '.KeyPairId' <<< "$KEYPAIR")
output "key_id: $key_id"
