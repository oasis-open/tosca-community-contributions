#!/bin/bash

# Check whether ip_address input is provided
if [ -z "${ip_address}" ]; then
    echo interface_name: " "
	exit 0
fi

# First get the interface name
addresses=$(ip -o -j address)
interface_name=$(jq -r --arg ip "$ip_address" \
    '.[].addr_info[] | select((.family=="inet") and (.local==$ip)) | .dev' \
    <<< "$addresses")

# Get the mac address as well
interfaces=$(ip -o -j link)
mac_address=$(jq -r --arg iface "$interface_name" \
    '.[] | select(.ifname==$iface) | .address' \
    <<< "$interfaces")

echo "interface_name: $interface_name"
echo "mac_address: $mac_address"
