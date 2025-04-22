#!/bin/bash

# LOG_FILE is set by the Executor

# Check that Environment Variables were set

if [ -z ${postgres_database_name} ]; then
	echo "Mandatory Environment Variable postgres_database_name is not set" >> "${LOG_FILE}"
	exit 10
fi

if [ -z ${postgres_username} ]; then
	echo "Mandatory Environment Variable postgres_username is not set" >> "${LOG_FILE}"
	exit 10
fi

# Create new database
sudo -u postgres createdb -O ${postgres_username} ${postgres_database_name} >> "${LOG_FILE}" 2>&1
