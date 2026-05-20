#!/bin/bash

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs az_credentials_file az_subnet_name az_vnet_name az_cidr_block az_group_name

az network vnet subnet create \
   --resource-group "$az_group_name" \
   --vnet-name "$az_vnet_name" \
   --address-prefixes "$az_cidr_block" \
   --name "$az_subnet_name"
