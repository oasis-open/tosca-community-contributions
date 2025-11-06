#!/bin/bash
set -e

# Set environment variables
HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. $HERE/env.sh

# Make sure CSAR directory exists
mkdir -p ${CSARS_DIR}

echo Creating core:0.1 CSAR file 
cd ${PROFILES_DIR}/community/tosca/core
zip -r ${CSARS_DIR}/community.tosca.core.0.1.csar . > /dev/null

echo Creating platform:0.1 CSAR file 
cd ${PROFILES_DIR}/community/tosca/platform
zip -r ${CSARS_DIR}/community.tosca.platform.0.1.csar . > /dev/null

echo Creating kubernetes:0.1 CSAR file 
cd ${PROFILES_DIR}/community/tosca/kubernetes
zip -r ${CSARS_DIR}/community.tosca.kubernetes.0.1.csar . > /dev/null

echo Creating microservices:0.1 CSAR file 
cd ${PROFILES_DIR}/community/tosca/microservices
zip -r ${CSARS_DIR}/community.tosca.microservices.0.1.csar . > /dev/null

echo Creating common:0.1 CSAR file 
cd ${PROFILES_DIR}/community/tosca/common
zip -r ${CSARS_DIR}/community.tosca.common.0.1.csar . > /dev/null

# Add profiles
echo Onboarding core:0.1
ubicity profile add ${CSARS_DIR}/community.tosca.core.0.1.csar > /dev/null

echo Onboarding platform:0.1
ubicity profile add ${CSARS_DIR}/community.tosca.platform.0.1.csar > /dev/null

echo Onboarding kubernetes:0.1
ubicity profile add ${CSARS_DIR}/community.tosca.kubernetes.0.1.csar > /dev/null

echo Onboarding microservices:0.1
ubicity profile add ${CSARS_DIR}/community.tosca.microservices.0.1.csar > /dev/null

echo Onboarding common:0.1
ubicity profile add ${CSARS_DIR}/community.tosca.common.0.1.csar > /dev/null

