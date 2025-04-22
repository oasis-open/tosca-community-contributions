#!/bin/bash

network_name='["one", "two", "three", "four"]'
ip_address='["null", "1.1.1.1", "2.2.2", "null"]'
mac_address='["ff.aa.xx", "null", "aa.bb.cc", "null"]'

# Networks are optional. If networks are configured then either all of
# them must specify an IP and MAC address or none of them must.
network_args=""
if [ ! -z ${network_name+x} ] && [ ! -z ${ip_address+x} ] && [ ! -z ${mac_address+x} ]; then
    i=0
    for network_id in $(jq -r '.[]' <<<$network_name);
    do
	ip_addr=$(jq -r ".[$i]" <<<$ip_address)
	mac_addr=$(jq -r ".[$i]" <<<$mac_address)
	if [ $ip_addr = "null" ] && [ $mac_addr = "null" ]; then
	    echo IP ADDRESS and MAC ADDRESS are NULL 
	    network_args+=" --network ${network_id} "
	elif [ $ip_addr != "null" ] && [ $mac_addr = "null" ]; then
	    echo IP ADDRESS is $ip_addr and MAC ADDRESS is NULL 
	    network_args+=" --network ${network_id} --ip ${ip_addr}"
	elif [ $ip_addr = "null" ] && [ $mac_addr != "null" ]; then
	    echo MAC ADDRESS is $mac_addr and IP ADDRESS is NULL 
	    network_args+=" --network ${network_id} --mac-address ${mac_addr}"
	else
	    echo IP ADDRESS is $ip_addr and MAC ADDRESS is $mac_addr 
	    network_args+=" --network ${network_id} --ip ${ip_addr} --mac-address ${mac_addr}"
	fi
	((i+=1))
    done
else
    echo "$container_name": no networks to connect to 
fi

echo $network_args
