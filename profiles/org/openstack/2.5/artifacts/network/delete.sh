#!/bin/bash

# This script expects the following environment variables:
#
#          os_network_id

# Activate virtual environment and set authentication variables.
HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../activate.sh"

init_output

require_inputs os_network_id

# Delete the network.
openstack network delete "$os_network_id"
