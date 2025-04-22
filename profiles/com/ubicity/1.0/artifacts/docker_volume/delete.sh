#!/bin/bash

if [  -z ${volume_id} ]; then
    # Must be an anonymous volume
    exit 0
fi

printf "Delete Docker Volume %s\n" "$volume_id"  >> ${LOG_FILE}
docker volume rm "$volume_id" >> $LOG_FILE 2>&1
