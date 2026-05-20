#!/bin/bash

# Check whether mac_address input is provided

if [ -z "${mac_address}" ]; then
    echo interface_name: " "
	exit 0
fi

# Case-insensitive comparison
interfaces=$(ip -o -j link)
interface_name=$(jq -r ".[] | select((.address|ascii_downcase)==\"${mac_address,,}\") | .ifname" <<< "$interfaces")

echo "interface_name: $interface_name"
