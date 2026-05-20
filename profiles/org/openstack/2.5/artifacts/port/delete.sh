#!/bin/bash

# Activate virtual environment and set authentication variables.
HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../activate.sh"

init_output

require_inputs port_id

# Delete the port.
openstack port delete "$port_id"
