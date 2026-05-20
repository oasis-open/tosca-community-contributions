#!/bin/bash

# This script expects the following Environment Variables:
#
#          key_name
#          key_file

# LOG_FILE is set by the Executor

# Activate virtual environment and set authentication variables.
HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../activate.sh"

init_output

require_inputs key_name key_file

# Delete keypair
openstack keypair delete "$key_name"

# Delete the key files from the credential vault
rm -f "${key_file}" "${key_file}.pub"

