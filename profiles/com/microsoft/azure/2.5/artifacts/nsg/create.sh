#!/bin/bash

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs az_credentials_file az_nsg_name az_region_name az_group_name

# First, create the network security group
az network nsg create \
   --location "$az_region_name" \
   --resource-group "$az_group_name" \
   --name "$az_nsg_name"

# Then, add each ingress rule
for rule in $(jq -c '.[]' <<< "$az_ingress_rules");
do
    RULE_ARGS=$(jq -r '. | "--name " + .name + " --priority " + (.priority|tostring) + " --protocol " + .protocol + " --destination-port-ranges " + (.port|tostring) + " --source-address-prefixes " + .cidr' <<< "$rule")
    az network nsg rule create \
       --resource-group "$az_group_name" \
       --direction Inbound \
       --access Allow \
       --nsg-name "$az_nsg_name" \
       $RULE_ARGS
done

# Finally, add each egress rule
for rule in $(jq -c '.[]' <<< "$az_egress_rules");
do
    RULE_ARGS=$(jq -r '. | "--name " + .name + " --priority " + (.priority|tostring) + " --protocol " + .protocol + " --destination-port-ranges " + (.port|tostring) + " --source-address-prefixes " + .cidr' <<< "$rule")
    az network nsg rule create \
       --resource-group "$az_group_name" \
       --direction Outbound \
       --access Allow \
       --nsg-name "$az_nsg_name" \
       $RULE_ARGS
done
