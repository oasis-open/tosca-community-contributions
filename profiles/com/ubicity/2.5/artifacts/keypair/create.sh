#!/bin/bash

# Script to create a key pair
set -e

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. $HERE/../common_lib.sh

init_output

# Make sure mandatory inputs are present
require_inputs vault key_type key_bits key_format

# Process optional inputs
if [ -z "${key_name}" ]; then
    # Key name is not set. Creating a name.
    SALT=$(md5sum <<<$RANDOM | head -c 10)
    key_name='ubct-'"${SALT}"
fi

# Make sure vault exists
VAULT="${vault//\~/$HOME}"
if [ ! -d "${VAULT}" ]; then
    sudo mkdir -p "${VAULT}"
    # Get user name and group name to set the correct ownership
    USER_NAME=$(id -un)
    GROUP_NAME=$(id -gn)
    sudo chown ${USER_NAME}.${GROUP_NAME} "${VAULT}"
fi

# Define the SSH key parameters
KEY_PATH=$VAULT/$key_name
COMMENT="ubicity-generated-key"

echo "Creating key ${KEY_PATH}"

# Generate the SSH key without prompting for input.
ssh-keygen -t "$key_type" -b "$key_bits" -C "$COMMENT" -m "$key_format" -f "$KEY_PATH" -N "" -q

# Return outputs
output key_name: $key_name
output key_file: $KEY_PATH
output public_key_file: $KEY_PATH.pub
