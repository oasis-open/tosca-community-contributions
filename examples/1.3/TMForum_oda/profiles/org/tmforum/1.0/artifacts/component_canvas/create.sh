#!/bin/bash

# This script expects the following environment variables:
#
# oda_component_definition_file_path
#

LOG_FILE=/tmp/oda_component.log

if [ -z ${oda_component_definition_file_path} ]; then
    echo "oda_component_definition_file_path is not set" >> $LOG_FILE
    exit 10
fi

oda_component_definition_file_path=${oda_component_definition_file_path}
echo "component file is $oda_component_definition_file_path"
# create the component in a pre-existing canvas enabled kubernetes cluster

#kubectl apply -f $oda_component_definition_file_path

output() {
    echo $@ 2>&1
}

output  "$oda_component_definition_file_path"