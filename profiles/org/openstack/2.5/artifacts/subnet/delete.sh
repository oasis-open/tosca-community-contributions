#!/bin/bash

# This script expects the following environment variables:
#
#          os_subnet_id
#
# LOG_FILE is set by the Executor

# Activate virtual environment and set authentication variables.
HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../activate.sh"

init_output

require_inputs os_subnet_id

# Delete the subnet.
openstack subnet delete "$os_subnet_id"
