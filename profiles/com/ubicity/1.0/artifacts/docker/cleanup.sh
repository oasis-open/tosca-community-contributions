#!/bin/bash

# Remove docker directories
sudo -n rm -rf /var/lib/docker >> ${LOG_FILE} 2>&1
sudo -n rm -rf /var/lib/containerd >> ${LOG_FILE} 2>&1
