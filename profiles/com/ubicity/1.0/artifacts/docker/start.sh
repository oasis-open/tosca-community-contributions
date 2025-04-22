#!/bin/bash
#
# This script starts Docker CE
#
# Copied from
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/
#
# Refer to https://docs.docker.com/engine/installation/ for more information
#

# Restart docker.
sudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl restart docker
