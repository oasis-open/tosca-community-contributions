#!/bin/bash

# LOG_FILE is set by the Executor

# Check that Environment Variables were set
if [ -z ${postgres_database_name} ]; then
	echo "Mandatory Environment Variable postgres_database_name is not set" >> "${LOG_FILE}"
	exit 10
fi

# Delete database
sudo -u postgres dropdb ${postgres_database_name} >> "${LOG_FILE}" 2>&1
