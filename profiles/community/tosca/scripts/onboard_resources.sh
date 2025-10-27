#!/bin/bash
set -e

# Set environment variables
HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. $HERE/env.sh

# Add services for available resources
deploy ${RESOURCES_DIR}/kubernetes_clusters
