#!/bin/bash

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs az_credentials_file az_vnet_name az_region_name az_group_name az_cidr_block

az network vnet create \
   --location "$az_region_name" \
   --resource-group "$az_group_name" \
   --address-prefixes "$az_cidr_block" \
   --name "$az_vnet_name"
