#!/bin/bash

# Check mandatory inputs
if [ -z ${name} ]; then
    echo "Mandatory input 'name' is missing" >> ${LOG_FILE}
    exit 10
fi

printf "Delete Docker MacVlan %s\n" "$name"  >> ${LOG_FILE}

docker network rm "$name" >> $LOG_FILE 2>&1
