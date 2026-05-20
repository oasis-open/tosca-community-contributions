#!/bin/bash

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs az_credentials_file az_group_name az_region_name

az group create --location "$az_region_name" --resource-group "$az_group_name"
