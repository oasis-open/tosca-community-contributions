#!/bin/bash

# LOG_FILE is set by the artifact processor

# Activate virtual environment and set authentication variables.
HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../activate.sh"

init_output

require_inputs network_name provider_type cloud_provider

# Create the network.
if [ "$cloud_provider" == "rackspace" ]; then
    NETWORK_INFO=$(openstack network create "$network_name" --format json)
else
    NETWORK_INFO=$(openstack network create --provider-network-type "$provider_type" "$network_name" --format json)
fi
output "$NETWORK_INFO"
