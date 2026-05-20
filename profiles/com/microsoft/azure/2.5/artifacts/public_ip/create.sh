#!/bin/bash

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs az_credentials_file az_public_ip_name az_region_name az_group_name az_version

RESULT=$(az network public-ip create \
   --location "$az_region_name" \
   --resource-group "$az_group_name" \
   --version "$az_version" \
   --sku Standard \
   --output json \
   --name "$az_public_ip_name")

az_ip_address=$(echo "$RESULT" | jq -r '.publicIp.ipAddress // empty')
output "az_ip_address: $az_ip_address"
