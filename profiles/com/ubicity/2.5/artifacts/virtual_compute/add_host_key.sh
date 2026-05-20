#!/bin/bash

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. $HERE/../common_lib.sh

init_output

require_inputs host

# Parse host into IP address and port
ip_address=$(jq -r '.ip_address' <<<"$host")
port=$(jq -r '.port' <<<"$host")

echo "Getting host key for host $ip_address on port $port.."

# Remove any old key(s)
host_id="$ip_address"
[ "$port" -ne 22 ] && host_id="[$ip_address]:$port"
ssh-keygen -R "$host_id" || true

# Wait until SSH is up
MAX_TRIES=10
COUNT=0

until nc -zv $ip_address $port 2>/dev/null; do
  ((COUNT++))
  if [ $COUNT -ge $MAX_TRIES ]; then
    echo "SSH never became available after $MAX_TRIES tries."
    exit 1
  fi
  echo "Waiting for SSH..."
  sleep 2
done

# Get the new host key
if [ "$port" -eq 22 ]; then
    ssh-keyscan -H "$ip_address" >> ~/.ssh/known_hosts
else
    ssh-keyscan -H -p "$port" "$ip_address" >> ~/.ssh/known_hosts
fi
