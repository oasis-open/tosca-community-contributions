#!/bin/bash

#
# Configure Minikube on Linux
#

# Create the 'minikube' user account. The '-m' flag makes sure that
# the home directory is created.
sudo useradd -m miniuser >> "${LOG_FILE}" 2>&1

# Add the 'minkube' user account to the 'docker' group
sudo usermod -aG docker miniuser >> "${LOG_FILE}" 2>&1

