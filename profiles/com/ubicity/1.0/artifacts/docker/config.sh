#!/bin/bash
#
# This script configures Docker Community Edition. Based on
#
# https://docs.docker.com/engine/install/ubuntu/
#
# Refer to https://docs.docker.com/engine/installation/ for more information
#
# LOG_FILE and USER are set by the artifact processor

## Add the user to the 'docker' group. Docker group may already exist.
sudo -n groupadd docker >> ${LOG_FILE} 2>&1 || true
sudo usermod -aG docker $USER  >> ${LOG_FILE} 2>&1

