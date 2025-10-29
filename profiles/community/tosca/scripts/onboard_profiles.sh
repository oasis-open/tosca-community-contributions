#!/bin/bash
set -e

# Set environment variables
HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. $HERE/env.sh

# Make sure CSAR directory exists
mkdir -p ${CSARS_DIR}

echo Creating platform:0.1 CSAR file 
cd ${PROFILES_DIR}/platform
zip -r ${CSARS_DIR}/platform.0.1.csar . > /dev/null

echo Creating kubernetes:0.1 CSAR file 
cd ${PROFILES_DIR}/kubernetes
zip -r ${CSARS_DIR}/kubernetes.0.1.csar . > /dev/null

echo Creating microservices:0.1 CSAR file 
cd ${PROFILES_DIR}/microservices
zip -r ${CSARS_DIR}/microservices.0.1.csar . > /dev/null

# Add profiles
echo Onboarding platform:0.1
ubicity profile add ${CSARS_DIR}/platform.0.1.csar > /dev/null

echo Onboarding kubernetes:0.1
ubicity profile add ${CSARS_DIR}/kubernetes.0.1.csar > /dev/null

echo Onboarding microservices:0.1
ubicity profile add ${CSARS_DIR}/microservices.0.1.csar > /dev/null
