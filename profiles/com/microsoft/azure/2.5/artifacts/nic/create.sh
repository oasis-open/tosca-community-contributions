#!/bin/bash

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs az_credentials_file az_nic_name az_subnet_name az_vnet_name az_group_name

OPTIONAL_ARGS=()
[ -n "${az_public_ip_address:-}" ] && OPTIONAL_ARGS+=(--public-ip-address "$az_public_ip_address")
[ -n "${az_security_group_name:-}" ] && OPTIONAL_ARGS+=(--network-security-group "$az_security_group_name")

az network nic create \
   --resource-group "$az_group_name" \
   --subnet "$az_subnet_name" \
   --vnet-name "$az_vnet_name" \
   "${OPTIONAL_ARGS[@]}" \
   --name "$az_nic_name"

# To debug effective security group rules:
# https://docs.microsoft.com/en-us/cli/azure/network/nic?view=azure-cli-latest#az_network_nic_list_effective_nsg
