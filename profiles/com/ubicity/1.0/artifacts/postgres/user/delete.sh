#!/bin/bash

# LOG_FILE is set by the Executor

# Check that Environment Variables were set

if [ -z ${postgres_username} ]; then
	echo "Mandatory Environment Variable postgres_username is not set" >> "${LOG_FILE}"
	exit 10
fi

# Delete user
sudo -u postgres dropuser ${postgres_username} >> "${LOG_FILE}" 2>&1

