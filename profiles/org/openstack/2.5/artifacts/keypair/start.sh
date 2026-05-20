#!/bin/bash

# This script expects the following environment variables:
#
#          key_name
#          public_key_file

# Activate virtual environment and set authentication variables.
HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../activate.sh"

init_output

require_inputs key_name public_key_file

# Upload the public key to OpenStack.
KEYPAIR_INFO=$(openstack keypair create --public-key "$public_key_file" \
          --format json \
          "$key_name")
echo "$KEYPAIR_INFO"
