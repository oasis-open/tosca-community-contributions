#!/bin/bash

# This script expects the following environment variables:
#
#          aws_credentials_file
#          aws_region_name
#          aws_subnet_id
#
# Optional environment variables:
#
#          aws_security_group_id
#          aws_profile

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs aws_region_name aws_subnet_id

# aws_security_group_id is optional.
SECURITY_GROUP_ARGS=()
[ -n "${aws_security_group_id}" ] && SECURITY_GROUP_ARGS=(--groups "$aws_security_group_id")

echo "aws ec2 create-network-interface --region $aws_region_name --subnet-id $aws_subnet_id ${SECURITY_GROUP_ARGS[*]}"

RESULT=$(aws ec2 create-network-interface \
	     --region    "$aws_region_name" \
	     --subnet-id "$aws_subnet_id" \
	     "${SECURITY_GROUP_ARGS[@]}" \
	     --output json)
if [ $? -ne 0 ] || [ -z "$RESULT" ]; then
    echo "ERROR: failed to create network interface"
    exit 1
fi

interface_id=$(jq -r '.NetworkInterface.NetworkInterfaceId' <<< "$RESULT")
ip_address=$(jq -r '.NetworkInterface.PrivateIpAddress' <<< "$RESULT")
mac_address=$(jq -r '.NetworkInterface.MacAddress' <<< "$RESULT")

output "interface_id: $interface_id"
output "ip_address: $ip_address"
output "mac_address: $mac_address"
