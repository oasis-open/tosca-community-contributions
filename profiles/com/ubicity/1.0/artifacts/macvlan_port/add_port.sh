#!/bin/bash

# Check mandatory inputs
if [ -z ${network_name} ]; then
    echo "Mandatory input 'network_name' is missing" >> ${LOG_FILE}
    exit 10
fi
if [ -z ${container_id} ]; then
    echo "Mandatory input 'container_id' is missing" >> ${LOG_FILE}
    exit 10
fi

# IP address is optional
if [ ! -z ${ip_address+x} ] && [ ! -z ${mac_address+x} ]; then
    ADDR_ARGS=" --ip $ip_address --mac-address $mac_address "
elif [ -z ${ip_address+x} ] && [ ! -z ${mac_address+x} ]; then
    ADDR_ARGS=" --mac-address $mac_address "
elif [ ! -z ${ip_address+x} ] && [ -z ${mac_address+x} ]; then
    ADDR_ARGS=" --ip $ip_address  "
else
    ADDR_ARGS=""
fi

# Connect the port
docker network connect "$network_name" "$container_id" $ADDR_ARGS  >> $LOG_FILE 2>&1 
       
