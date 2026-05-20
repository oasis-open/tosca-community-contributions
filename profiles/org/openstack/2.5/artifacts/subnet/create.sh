#!/bin/bash

# This script expects the following environment variables:
#
#          os_subnet_name
#          os_subnet_cidr
#          os_subnet_enable_dhcp
#          os_subnet_network_id

# Activate virtual environment and set authentication variables.
HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../activate.sh"

init_output

require_inputs os_subnet_name os_subnet_network_id os_subnet_cidr os_subnet_enable_dhcp

# Create the subnet.
DHCP_FLAG="--dhcp"
if [ "$os_subnet_enable_dhcp" != "true" ]; then
    DHCP_FLAG="--no-dhcp"
fi

SUBNET_INFO=$(openstack subnet create "$os_subnet_name" \
	  --network "$os_subnet_network_id" \
	  --subnet-range "$os_subnet_cidr" \
	  "$DHCP_FLAG" \
	  --format json)
output "$SUBNET_INFO"
