#!/bin/bash

if [ -z ${monitor_id} ]; then
    echo "Mandatory input 'monitor_id' is missing" >> ${LOG_FILE}
    exit 10
fi

# Stop the monitor
kill -9 $monitor_id >> $LOG_FILE 2>&1
