#!/bin/bash

#
# Install Minikube on Linux
#

# Download Minikube package
cd /tmp
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb >> "${LOG_FILE}" 2>&1

# Install
sudo dpkg -i minikube_latest_amd64.deb >> "${LOG_FILE}" 2>&1

