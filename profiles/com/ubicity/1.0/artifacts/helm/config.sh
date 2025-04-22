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

HELMVERSION=${helm_version}

# Initialize if Helm Version 2
if [[ ${HELMVERSION} == 2.* ]]; then
    cd ~/
    export HELM_HOME="$(pwd)/.helm"
    helm init --home ${HELM_HOME} --service-account tiller  >> "${LOG_FILE}" 2>&1
    # Make sure tiller pod is running
    sleep 60
fi


