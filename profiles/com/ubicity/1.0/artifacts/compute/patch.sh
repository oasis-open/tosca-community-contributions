#!/bin/bash

# Make sure no other process is updating package lists or installing
# packages. Wait for up to two minutes.
RETRY_COUNT=24   # Number of times to retry
RETRY_SLEEP=5    # How many seconds to sleep before trying again
echo "Applying patches" >> $LOG_FILE
until sudo -n apt-get -q -y update >> ${LOG_FILE} 2>&1 \
    && sudo -n apt-get -q -y upgrade >> ${LOG_FILE} 2>&1; do
    if [[ "${RETRY_COUNT}" -eq 0 ]]; then
	exit 1;
    fi
    sleep ${RETRY_SLEEP}
    (( RETRY_COUNT-- ))
    echo Retry upgrading  >> ${LOG_FILE} 2>&1
done

# Cleanup
sudo -n apt-get -q -y autoremove >> ${LOG_FILE} 2>&1 
