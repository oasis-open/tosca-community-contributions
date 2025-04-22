#!/bin/bash

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

echo $ADDR_ARGS
