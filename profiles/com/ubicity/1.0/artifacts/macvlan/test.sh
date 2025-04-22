#!/bin/bash

#mac_address=00:0c:29:ce:2f:74
#mac_address=00:00:00:00:00:00
#mac_address=00:0c:29:ce:2f:74

interface_name=$(docker exec $container_name ip -o link | grep $mac_address| awk '{print substr($2, 1, length($2)-1)}' 2>> $LOG_FILE)
echo interface_name: $interface_name
