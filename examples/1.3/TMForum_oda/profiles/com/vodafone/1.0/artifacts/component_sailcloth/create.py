#!/usr/bin/env python3
# 
#create a file structure which emulates and ODA component on canvas

# This script expects the following environment variables:
#
#          oda_component_instance_name
#          oda_component_defn (a filespec to the yaml file)
#          oda_component_sailcloth (a directory where the emulator files are stored

from types import TracebackType
import yaml
import os
import logging
import sys

def main():

    # Make a log file and set it
    log_file_path='/tmp/create_component_sailcloth.log'
    split_log_file_path = os.path.split(log_file_path)
    if not os.path.exists(split_log_file_path[0]):
        os.makedirs(split_log_file_path[0])
    logging.basicConfig(filename = log_file_path , level = logging.ERROR)

        # Set constants
    #config_file_name = "connections.yaml"
    # Get environment variables
    oda_component_instance_name = os.getenv('oda_component_instance_name')
    oda_component_defn = os.getenv('oda_component_defn')
    oda_component_sailcloth = os.getenv('oda_component_sailcloth')
    logging.debug('oda_component_instance_name:'+ str(oda_component_instance_name))
    logging.debug('oda_component_defn:'+ str(oda_component_defn))
    logging.debug('oda_component_sailcloth:'+ str(oda_component_sailcloth))

    #Create a directory for the instance
    instance_dir=oda_component_sailcloth+oda_component_instance_name
    #TODO make this shel script into python
    # if [ ! -d "$INSTANCE_DIR" ]; then
    #     mkdir -p $INSTANCE_DIR
    # fi
    #Copy the def file to the instance directory
    #cp $oda_component_defn $INSTANCE_DIR/spec.yaml
    #Create a file of links from requirements of this instance to other instances which contain the capabilities
    # #TODO make this a relative path
    # echo "CREATING" > /tmp/mydebug
    # echo $PWD >> /tmp/mydebug
    # /home/jordanpm/tosca/profiles/org/tmforum/1.0/artifacts/component_sailcloth/makeconfig.py $INSTANCE_DIR

    # #get an attribute of the file as a single string
    # SAP=$INSTANCE_DIR 

    # output() {
    #     echo $@ 2>&1
    # }

    # output  "oda_component_sap: $SAP"

def get_spec_yaml_dir(): 
    # 
    return(TODO instance_dir)

def extract_apis(component_yaml):
    # takes a a path to a component yaml file and returns a dict of caps and reqs
    with open(component_yaml) as f:
        docs = yaml.safe_load_all(f)
        for doc in docs:
            if doc["kind"] == 'component':
                caps=doc['spec']['coreFunction']['exposedAPIs']
                reqs=doc['spec']['coreFunction']['dependantAPIs']
                # for cap in caps:
                #     print(cap['name'])
                # for req in reqs:
                #     print(req['name'])
    return {'caps': caps, 'reqs': reqs}

def make_connections(apis):
    connections = []
    reqs=apis["reqs"]
    if reqs:
        for req in reqs:
            req["source_instance_name"] = ""
            connections.append(req)
        return(connections)
    else:
        return
    

def makeconfig():
    spec_dir=get_spec_yaml_dir()
    spec_file="spec.yaml"
    config_file="connections.yaml"
    apis=extract_apis(spec_dir+"/"+spec_file)
    connections=make_connections(apis)
    output_path=spec_dir+"/"+config_file
    with open(output_path, 'w') as file:
        yaml.dump(connections, file)

if __name__ == "__main__":
    exit(main())