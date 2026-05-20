#!/bin/bash

# This script expects the following environment variables:
#
#          os_server_id

# Activate virtual environment and set authentication variables.
HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../activate.sh"

init_output

require_inputs os_server_id

# Delete the server.
openstack server delete "$os_server_id"
