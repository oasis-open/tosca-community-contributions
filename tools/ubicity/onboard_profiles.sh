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

echo Creating base:0.1 CSAR file 
cd ${PROFILES_DIR}/community/tosca/base
zip -r ${CSARS_DIR}/community.tosca.base.0.1.csar . > /dev/null

echo Creating platform:0.1 CSAR file 
cd ${PROFILES_DIR}/community/tosca/platform
zip -r ${CSARS_DIR}/community.tosca.platform.0.1.csar . > /dev/null

echo Creating network:0.1 CSAR file 
cd ${PROFILES_DIR}/community/tosca/network
zip -r ${CSARS_DIR}/community.tosca.network.0.1.csar . > /dev/null

echo Creating data:0.1 CSAR file 
cd ${PROFILES_DIR}/community/tosca/data
zip -r ${CSARS_DIR}/community.tosca.data.0.1.csar . > /dev/null

echo Creating application:0.1 CSAR file 
cd ${PROFILES_DIR}/community/tosca/application
zip -r ${CSARS_DIR}/community.tosca.application.0.1.csar . > /dev/null

echo Creating kubernetes:0.1 CSAR file 
cd ${PROFILES_DIR}/community/tosca/kubernetes
zip -r ${CSARS_DIR}/community.tosca.kubernetes.0.1.csar . > /dev/null

# Add profiles
echo Onboarding core:0.1
ubicity profile add ${CSARS_DIR}/community.tosca.core.0.1.csar > /dev/null

echo Onboarding base:0.1
ubicity profile add ${CSARS_DIR}/community.tosca.base.0.1.csar > /dev/null

echo Onboarding platform:0.1
ubicity profile add ${CSARS_DIR}/community.tosca.platform.0.1.csar > /dev/null

echo Onboarding network:0.1
ubicity profile add ${CSARS_DIR}/community.tosca.network.0.1.csar > /dev/null

echo Onboarding data:0.1
ubicity profile add ${CSARS_DIR}/community.tosca.data.0.1.csar > /dev/null

echo Onboarding application:0.1
ubicity profile add ${CSARS_DIR}/community.tosca.application.0.1.csar > /dev/null

echo Onboarding kubernetes:0.1
ubicity profile add ${CSARS_DIR}/community.tosca.kubernetes.0.1.csar > /dev/null

