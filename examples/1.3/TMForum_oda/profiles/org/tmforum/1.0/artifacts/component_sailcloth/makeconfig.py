#!/usr/bin/env python3
# 
# #create a config file which is used as part of emulator of ODA component on canvas
# The file records linkages from the emulated module to other modules which provide the required APIs

# This script expects the following argument:
#
#          path to an ODA component spec file

import yaml
import sys

def get_spec_yaml_dir(): 
    if len(sys.argv) != 2:
        raise ValueError('Please provide a directory argument.')
    return(sys.argv[1])

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
    

def main():
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