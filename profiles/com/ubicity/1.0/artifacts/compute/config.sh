#!/bin/bash

# Make sure the log file exists and writable by everyone
LOG_DIR=$(dirname $LOG_FILE)
mkdir -p $LOG_DIR && touch $LOG_FILE
chmod a+w $LOG_FILE

# Install platform packages
PLATFORM_PACKAGES="jq ca-certificates curl gnupg"
echo Installing platform packages $PLATFORM_PACKAGES  >> ${LOG_FILE} 2>&1

# Make sure no other process is updating package lists or installing
# packages. Wait for up to two minutes.
RETRY_COUNT=24   # Number of times to retry
RETRY_SLEEP=5    # How many seconds to sleep before trying again
until sudo -n apt-get -y update >> ${LOG_FILE} 2>&1 \
    && sudo -n apt-get -y install ${PLATFORM_PACKAGES} >> ${LOG_FILE} 2>&1; do
    if [[ "${RETRY_COUNT}" -eq 0 ]]; then
	exit 1;
    fi
    sleep ${RETRY_SLEEP}
    (( RETRY_COUNT-- ))
    echo Retry updating packages  >> ${LOG_FILE} 2>&1
done
