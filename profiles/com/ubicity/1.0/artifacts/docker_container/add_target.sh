#!/bin/bash

# Get mac and IP addresses
echo Getting MAC address for MacVLAN $name connected to container $container_id  >> $LOG_FILE
mac_address=$(docker inspect $container_id | jq -r ".[0].NetworkSettings.Networks[\"$name\"].MacAddress" 2>> $LOG_FILE )
ip_address=$(docker inspect $container_id | jq -r ".[0].NetworkSettings.Networks[\"$name\"].IPAddress" 2>> $LOG_FILE )

echo Getting MacVLAN interface name for $mac_address >> $LOG_FILE
docker exec $container_id ip -o link >> $LOG_FILE

interface_name=$(docker exec $container_id ip -o link | grep $mac_address| awk '{print substr($2, 1, length($2)-1)}' 2>> $LOG_FILE)
echo interface_name: $interface_name
echo mac_address: $mac_address
echo ip_address: $ip_address
