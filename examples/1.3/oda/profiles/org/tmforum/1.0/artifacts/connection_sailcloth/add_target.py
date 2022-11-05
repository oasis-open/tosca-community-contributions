#!/usr/bin/env python3
#
# update a connections file which is used as part of emulator of ODA component on canvas
# The file records linkages from the emulated module to other modules
# which provide the required APIs

# This script expects the following environment variables:
#
#          oda_component_api_connection_source, which in this emulator is an instance name which can be used to infer the connections file
#          oda_component_api_connection_target, which would normally be the IP address but in this emulator is the target instance name
#          sailcloth_directory
#          oda_api_connection_name, the name of the api being connected

from types import TracebackType
import yaml
import os
import logging



def main():

    # Make a log file and set it
    log_file_path='/tmp/add_target.log'
    split_log_file_path = os.path.split(log_file_path)
    if not os.path.exists(split_log_file_path[0]):
        os.makedirs(split_log_file_path[0])
    logging.basicConfig(filename = log_file_path , level = logging.ERROR)

    # Set constants
    config_file_name = "connections.yaml"
    # Get environment variables
    sailcloth_dir = os.getenv('sailcloth_directory')
    source_name = os.getenv('oda_component_api_connection_source')
    target_name = os.getenv('oda_component_api_connection_target')
    api_name= os.getenv('oda_api_connection_name')
    logging.debug('sailcloth_dir:'+ str(sailcloth_dir))
    logging.debug('source_name:'+ str(source_name))
    logging.debug('target_name:'+ str(target_name))
    logging.debug('api_name:'+ str(api_name))
    # Calculate file name
    source_connections_file = sailcloth_dir + "/" + source_name + "/" + config_file_name
    ## Modify source_connections_file
    # read the file
    try:
        with open(source_connections_file, 'r') as file:
            connections=yaml.safe_load(file)
    except IOError:
        logging.error('Unable to read file:'+source_connections_file)
        return("Error : true")

    logging.debug('connections:'+str(connections))

    
    #Find an entry in the list of dictionary which matches the api name
    e=(next((i for i, x in enumerate(connections) if x["name"] == api_name), None))
    #Update that dictionary with the new target name
    (connections[e])["source_instance_name"]=target_name
    # Write the new list of dictionaries to the file
    logging.debug('Connections are:'+str(connections))

    try:
        with open(source_connections_file, 'w') as file:
            yaml.dump(connections,file)
        # Return a dummy documentation IP address as the sap of the component providing the API
        # TODO could create the dummy IP address when each componenet is created and pick it up for use here
        logging.debug('outputting dummy sap')
        print("oda_component_sap: 203.0.113.1")
    except IOError:
        logging.error('Unable to write file:'+source_connections_file)
        logging.debug('returning error')
        return("Error : true")

if __name__ == "__main__":
    exit(main())
