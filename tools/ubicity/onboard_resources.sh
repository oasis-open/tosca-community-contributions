#!/bin/bash
set -e

# Set environment variables
HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. $HERE/env.sh

# Add services for available platform resources
deploy ${EXAMPLES_DIR}/kubernetes_clusters
