#!/bin/bash

# LOG_FILE is set by the Executor

# This script expects the following environment variables:
#
# helm_version
#
if [ -z ${helm_version} ]; then
    echo "helm_version is not set" >> "${LOG_FILE}"
    exit 10
fi

# Install servcm plug-in for serving local repositories
if [[ ${helm_version} == 3.* ]]; then
    # Make sure servcm plugin is not already installed
    helm plugin list | grep -q "^servecm"
    if [ $? -eq "1" ]; then
	helm plugin install https://github.com/jdolitsky/helm-servecm >> "${LOG_FILE}" 2>&1
    fi
fi

