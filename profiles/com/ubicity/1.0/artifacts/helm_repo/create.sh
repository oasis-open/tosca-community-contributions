#!/bin/bash

# This script expects the following Environment Variables:
#
#          repo_name
#          repo_url

# LOG_FILE is set by the Executor

# Check that Environment Variables were set

if [ -z ${repo_name} ]; then
	echo "Mandatory Environment Variable repo_name is not set" >> ${LOG_FILE}
	exit 10
fi

if [ -z ${repo_url} ]; then
	echo "Mandatory Environment Variable repo_url is not set" >> ${LOG_FILE}
	exit 10
fi

# Add the helm repo
helm repo add $repo_name $repo_url >> ${LOG_FILE} 2>&1


    
