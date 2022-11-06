#!/bin/bash

#create a file structure which emulates and ODA component on canvas

# This script expects the following environment variables:
#
#          oda_component_instance_name
#          oda_component_defn (a filespec to the yaml file)
#          oda_component_sailcloth (a directory where the emulator files are stored


DEBUG=0

if [ $DEBUG -eq 1 ]; then
    echo "in debug mode"
    oda_component_instance_name="debug.component"
    oda_component_defn="/home/jordanpm/Workspace/tosca/profiles/org/tmforum/1.0/artifacts/component_sailcloth/debug.component.yaml"
    oda_component_sailcloth="/home/jordanpm/Workspace/tosca/sailcloth"
fi


#Create a directory for the instance
INSTANCE_DIR=$oda_component_sailcloth"/"$oda_component_instance_name
if [ ! -d "$INSTANCE_DIR" ]; then
    mkdir -p $INSTANCE_DIR
fi

#Copy the def file to the instance directory
cp $oda_component_defn $INSTANCE_DIR/spec.yaml

#Create a file of links from requirements of this instance to other instances which contain the capabilities
#TODO make this a relative path
/home/jordanpm/Workspace/tosca/profiles/org/tmforum/1.0/artifacts/component_sailcloth/makeconfig.py $INSTANCE_DIR

#get an attribute of the file as a single string
SAP=$INSTANCE_DIR 

output() {
    echo $@ 2>&1
}

output  "oda_component_sap: $SAP"