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

# Download the Helm binary
HELMVERSION=${helm_version}
cd /tmp
if [ ! -e helm-v${HELMVERSION}-linux-amd64.tar.gz ]; then
    wget https://get.helm.sh/helm-v${HELMVERSION}-linux-amd64.tar.gz >> "${LOG_FILE}" 2>&1
fi

# Unpack
tar -xvf /tmp/helm-v${HELMVERSION}-linux-amd64.tar.gz >> "${LOG_FILE}" 2>&1

# Install in /usr/local/bin
sudo -n mv linux-amd64/helm /usr/local/bin/helm >> "${LOG_FILE}" 2>&1

