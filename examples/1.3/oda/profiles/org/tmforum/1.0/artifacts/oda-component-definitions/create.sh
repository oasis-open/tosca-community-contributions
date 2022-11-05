#!/bin/bash
# Install an old version of canvas from the repo at https://github.com/tmforum-rand/oda-component-definitions
# Expects the following environment variables
# GITHUBCREDS comprising github username followed by colon and followed by a github token


cd ~
git clone https://$GITHUBCREDS@github.com/tmforum-rand/oda-component-definitions
cd oda-component-definitions
./installCanvas.sh

# get errors
# Step 2b - Creating the Custom Resource Definitions (CRDs) that KOPF uses.
# customresourcedefinition.apiextensions.k8s.io/clusterkopfpeerings.zalando.org unchanged
# customresourcedefinition.apiextensions.k8s.io/kopfpeerings.zalando.org unchanged
# clusterkopfpeering.zalando.org/default created
# kopfpeering.zalando.org/default created

# Step 2c - Creating the ODAcomponents_dependantcontroller deployment.
# error: the path "componentOperator-manifest.yaml" does not exist
