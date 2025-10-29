#!/bin/bash
set -e

# Set environment variables
HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. $HERE/env.sh

# Make sure CSAR directory exists
mkdir -p ${CSARS_DIR}

cd ${SUBSTITUTIONS_DIR}/microservice
zip -r ${CSARS_DIR}/microservice.csar .

# Onboard substitutions
ubicity catalog add ${CSARS_DIR}/microservice.csar
