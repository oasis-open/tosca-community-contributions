#!/bin/bash
#
# This script starts Containerd CE
#
# Copied from
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/
#
# Refer to https://docs.docker.com/engine/installation/ for more information
#

# Restart containerd.
sudo systemctl enable containerd
sudo systemctl daemon-reload
sudo systemctl restart containerd
