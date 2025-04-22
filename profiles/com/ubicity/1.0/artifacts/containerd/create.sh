#!/bin/bash
#
# This script installs containerd
#
#    LOG_FILE (Set by the Executor)

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg 2>> ${LOG_FILE} | sudo -n gpg --dearmor -o /usr/share/keyrings/docker.gpg >> ${LOG_FILE} 2>&1
sudo -n chmod a+r /usr/share/keyrings/docker.gpg >> ${LOG_FILE} 2>&1

# Add Docker apt repository.
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo -n tee /etc/apt/sources.list.d/docker.list >> ${LOG_FILE} 2>&1

## Install Docker CE.
sudo -n apt-get update >> ${LOG_FILE} 2>&1
sudo -n apt-get install -y containerd.io  >> ${LOG_FILE} 2>&1
