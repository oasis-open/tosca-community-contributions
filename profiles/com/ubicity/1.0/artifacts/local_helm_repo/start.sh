#!/bin/bash
#
# This script expects the following environment variables:
#

# LOG_FILE is set by the Executor

#Check for helm3
IS_HELM3=$(helm version -c --short|grep -e "^v3")
HELM_HOME=~/.helm

# Start Helm local repo if there isn't one
ps -ax | grep  "helm serve" | grep -v "grep" >> ${LOG_FILE}
HELM_REPO_PID=$(ps -ax | grep  "helm serve" | grep -v "grep" | awk '{print $1}')
if [ -z "$HELM_REPO_PID" ]; then
    if [ -z $IS_HELM3 ]
    then
      cd ~/
      nohup /usr/local/bin/helm serve >> "${LOG_FILE}" 2>&1 & disown
    else
      echo HELM3 >> ${LOG_FILE}
      eval $(helm env |grep HELM_REPOSITORY_CACHE)
      echo yes > /tmp/ric-yes
      nohup helm servecm --port=8879 --context-path=/charts --storage local --storage-local-rootdir $HELM_REPOSITORY_CACHE/local/ < /tmp/ric-yes >> ${LOG_FILE} 2>&1 & disown
    fi
fi

# Add the repo
helm repo add local http://localhost:8879/charts >> "${LOG_FILE}" 2>&1

# Support for uploading:
# https://github.com/helm/chartmuseum
