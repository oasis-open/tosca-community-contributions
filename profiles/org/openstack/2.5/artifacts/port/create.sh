#!/bin/bash

# Activate virtual environment and set OS_CLOUD / OS_CLIENT_CONFIG_FILE.
HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../activate.sh"

init_output

require_inputs port_name subnet_id network_id cloud_provider

# Set arguments
ARGS=("--network" "$network_id")
if [ -n "${server_id}" ]; then
    ARGS+=("--host" "$server_id")
fi
if [ -n "${mac_address}" ]; then
    ARGS+=("--mac-address" "$mac_address")
fi
if [ -n "${ip_address}" ]; then
    ARGS+=("--fixed-ip" "subnet=$subnet_id,ip-address=$ip_address")
else
    ARGS+=("--fixed-ip" "subnet=$subnet_id")
fi

# Create port. Rackspace does not support 'openstack port create'; use nova instead.
# Nova does not honour OS_CLOUD, so extract the individual OS_* variables from
# the resolved configuration using the openstack CLI.
if [ "$cloud_provider" == "rackspace" ]; then
    eval "$(python3 -c "
import yaml, os
with open(os.environ['OS_CLIENT_CONFIG_FILE']) as f:
    clouds = yaml.safe_load(f)
auth = clouds['clouds'][os.environ['OS_CLOUD']]['auth']
print('export OS_AUTH_URL=' + repr(auth['auth_url']))
print('export OS_USERNAME=' + repr(auth['username']))
print('export OS_PASSWORD=' + repr(auth['password']))
tid = auth.get('project_id', auth.get('tenant_id', ''))
print('export OS_TENANT_ID=' + repr(tid))
")"
    require_inputs server_id
    PORT_INFO=$(nova virtual-interface-create "$network_id" "$server_id")
    echo "$PORT_INFO"
    port_id=$(echo "$PORT_INFO"    | awk -F'|' '/\| id /{gsub(/ /, "", $3); print $3}')
    ip_addr=$(echo "$PORT_INFO"    | awk -F'|' '/\| ip_addresses /{print $3}' | sed 's/.*ip_address=\([^,[:space:]]*\).*/\1/')
    mac_addr=$(echo "$PORT_INFO"   | awk -F'|' '/\| mac_address /{gsub(/ /, "", $3); print $3}')
    PORT_OUTPUT=$(jq -n --arg id "$port_id" --arg ip "$ip_addr" --arg mac "$mac_addr" \
        '{id: $id, ip_address: $ip, mac_address: $mac}')
else
    PORT_INFO=$(openstack port create -f json "${ARGS[@]}" "$port_name")
    echo "$PORT_INFO"
    PORT_OUTPUT=$(echo "$PORT_INFO" | jq '{id:.id, ip_address:.fixed_ips[0].ip_address, mac_address:.mac_address}')
fi

# Return output values
output "$PORT_OUTPUT"
