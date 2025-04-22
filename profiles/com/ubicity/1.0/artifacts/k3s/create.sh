#!/bin/bash

#
# Install K3s on Linux
#

# Download K3s package
cd /tmp
curl -sfL https://get.k3s.io | sh - >> "${LOG_FILE}" 2>&1
