#!/bin/bash

# This script expects the following environment variables:
#
# oda_component_name
# 
# TODO be supplied instead with the path name to the component defintion file and extract the name of the deployment from that file 
#
if [ -z ${oda_component_name} ]; then
    echo "oda_component_name is not set" >> /tmp/linuxfile.log
    exit 10
fi

oda_component_deployment_name=${oda_component_name}

kubectl delete deployment $oda_component_deployment_name