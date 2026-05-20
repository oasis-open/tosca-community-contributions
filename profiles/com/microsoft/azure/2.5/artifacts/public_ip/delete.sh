#!/bin/bash

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs az_credentials_file az_public_ip_name az_group_name

az network public-ip delete \
   --resource-group "$az_group_name" \
   --name "$az_public_ip_name"
