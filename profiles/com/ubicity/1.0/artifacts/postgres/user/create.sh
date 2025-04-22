#!/bin/bash

# LOG_FILE is set by the Executor

# Check that Environment Variables were set

if [ -z ${postgres_username} ]; then
	echo "Mandatory Environment Variable postgres_username is not set" >> "${LOG_FILE}"
	exit 10
fi

if [ -z ${postgres_password} ]; then
	echo "Mandatory Environment Variable postgres_password is not set" >> "${LOG_FILE}"
	exit 10
fi


# Create new user
sudo -u postgres createuser ${postgres_username} >> "${LOG_FILE}" 2>&1

echo "alter user ${postgres_username} with password '${postgres_password}'" >> "${LOG_FILE}" 2>&1

# Set the password for the new user
sudo -u postgres psql -c "alter user ${postgres_username} with password '${postgres_password}'" >> "${LOG_FILE}" 2>&1


