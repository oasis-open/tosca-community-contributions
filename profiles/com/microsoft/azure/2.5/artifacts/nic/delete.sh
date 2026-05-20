#!/bin/bash

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs az_credentials_file az_nic_name az_group_name

az network nic delete \
   --resource-group "$az_group_name" \
   --name "$az_nic_name"
