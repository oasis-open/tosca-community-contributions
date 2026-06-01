#!/bin/bash

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. $HERE/../common_lib.sh

init_output

require_inputs host

# Parse host into IP address and port
ip_address=$(jq -r '.ip_address' <<<"$host")
port=$(jq -r '.port' <<<"$host")

echo "Removing host key for host $ip_address on port $port.."

# Build host_id (non-standard port uses bracket notation)
host_id="$ip_address"
[ "$port" -ne 22 ] && host_id="[$ip_address]:$port"

ssh-keygen -R "$host_id" || true
