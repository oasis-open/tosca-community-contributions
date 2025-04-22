#!/bin/bash

# Check whether ip_address input is provided
if [ -z ${ip_address} ]; then
    echo interface_name: " "
	exit 0
fi

# First get the interface name 
addresses=$(ip -o -j address)
interface_name=$(jq ".[].addr_info[] | select((.family==\"inet\") and (.local==\"$ip_address\")) | .dev " <<<$addresses)

# Get the mac address as well
interfaces=$(ip -o -j link)
mac_address=$(jq ".[] | select(.ifname==$interface_name) | .address " <<<$interfaces)

echo interface_name: $interface_name
echo mac_address: $mac_address
