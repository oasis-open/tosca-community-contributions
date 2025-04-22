#!/bin/bash

# Check mandatory inputs
if [ -z ${name} ]; then
    echo "Mandatory input 'name' is missing" >> ${LOG_FILE}
    exit 10
fi
if [ -z ${parent_interface} ]; then
    echo "Mandatory input 'parent_interface' is missing" >> ${LOG_FILE}
    exit 10
fi
if [ -z ${cidr_block} ]; then
    echo "Mandatory input 'cidr_block' is missing" >> ${LOG_FILE}
    exit 10
fi

# Gateways are optional.
if [ ! -z ${gateway+x} ]; then
    gateway_arg="--gateway=$gateway"
else
    gateway_arg=""
fi

# IP ranges are optional.
if [ ! -z ${ip_range+x} ]; then
    ip_range_arg="--ip-range=$ip_range"
else
    ip_range_arg=""
fi
		       
# Create Mac VLAN
docker network create -d macvlan \
       -o parent="$parent_interface" \
       --subnet="$cidr_block" $gateway_arg $ip_range_arg \
       "$name" >> $LOG_FILE 2>&1

# Return macvlan details for this macvlan
macvlan_details=$(docker network inspect -f json "$name" 2>> ${LOG_FILE})
jq '.[0]' <<<$macvlan_details


				      
