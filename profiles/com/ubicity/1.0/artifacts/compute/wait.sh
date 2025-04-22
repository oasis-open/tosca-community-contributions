#!/bin/bash

if [ -z ${host} ]; then
    echo "Mandatory input 'host' is missing" >> ${LOG_FILE}
    exit 10
fi

RETRY_COUNT=30   # Number of times to retry
RETRY_SLEEP=10   # How many seconds to sleep before trying again

echo -n "Wait for reboot " >> ${LOG_FILE} 2>&1
sleep ${RETRY_SLEEP}
(( RETRY_COUNT-- ))
while ! nc -w 3 -z ${host} 22 2> /dev/null
do
    if [[ "${RETRY_COUNT}" -eq 0 ]]; then
	echo "Reboot timed out" >> ${LOG_FILE} 2>&1
	exit 1;
    fi
    echo -n . >> ${LOG_FILE}
    sleep ${RETRY_SLEEP}
    (( RETRY_COUNT-- ))
done
echo "" >> $LOG_FILE
echo "Reboot complete" >> $LOG_FILE

