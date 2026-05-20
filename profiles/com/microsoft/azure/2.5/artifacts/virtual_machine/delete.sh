#!/bin/bash

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs az_credentials_file az_instance_name az_group_name

az vm delete \
   --yes \
   --resource-group "$az_group_name" \
   --name "$az_instance_name"
