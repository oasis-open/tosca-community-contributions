#!/bin/bash

# Check mandatory inputs
if [ -z ${container_id} ]; then
    echo "Mandatory input 'container_id' is missing" >> ${LOG_FILE}
    exit 10
fi

printf "Delete Docker Container %s\n" "$container_id"  >> ${LOG_FILE}

docker rm "$container_id" >> $LOG_FILE 2>&1
