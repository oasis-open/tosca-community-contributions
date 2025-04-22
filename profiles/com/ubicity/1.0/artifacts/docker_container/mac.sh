#!/bin/bash

network_name="eth0"
ip_address="192.168.85.135"
mac_address="af.af.af.af.af"

# Network is optional. 
if [ ! -z ${network_name} ]; then
    if [ -z ${ip_address} ] && [ -z $mac_address} ]; then
	echo IP ADDRESS and MAC ADDRESS are NULL 
	network_args=" --network ${network_name} "
    elif [ ! -z ${ip_address} ] && [ -z ${mac_address} ]; then
	echo IP ADDRESS is $ip_address and MAC ADDRESS is NULL 
	network_args=" --network ${network_name} --ip ${ip_address}"
    elif [ -z ${ip_address} ] && [ ! -z ${mac_address} ]; then
	echo MAC ADDRESS is $mac_address and IP ADDRESS is NULL 
	network_args=" --network ${network_name} --mac-address ${mac_address}"
    else
	echo IP ADDRESS is $ip_address and MAC ADDRESS is $mac_address 
	network_args=" --network ${network_name} --ip ${ip_address} --mac-address ${mac_address}"
    fi
else
    echo "$container_name": no network to connect to 
fi
