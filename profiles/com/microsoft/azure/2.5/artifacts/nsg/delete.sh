#!/bin/bash

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs az_credentials_file az_nsg_name az_group_name

az network nsg delete \
   --resource-group "$az_group_name" \
   --name "$az_nsg_name"
