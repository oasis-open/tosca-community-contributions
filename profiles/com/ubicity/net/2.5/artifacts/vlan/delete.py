# 
# Delete VLAN on Cisco switch
#
__author__ = "Chris Lauwers"
__copyright__ = "Copyright (c) 2025, Ubicity Corp."
__email__ = "lauwers@ubicity.com"

import os
import sys
current = os.path.dirname(os.path.realpath(__file__))
parent = os.path.dirname(current)
sys.path.append(parent)

# Netmiko connections
import netmiko_connection

log_file_name = os.environ['LOG_FILE']

def main():
    try:
        with open(log_file_name, "a") as log_file:
            try:
                # Check mandatory inputs
                if not 'vlan_id' in os.environ or not os.environ['vlan_id']:
                    log_file.write("Mandatory input 'vlan_id' is missing\n")

                # Commands to delete the vlan
                commands = [
                    f"no vlan {os.environ['vlan_id']}",
                    "exit",
                ]

                # Establish connection
                connection = netmiko_connection.establish(log_file)
                
                # Send configuration commands
                log_file.write("[INFO] Sending configuration commands...\n")
                output = connection.send_config_set(commands)
                log_file.write(output)

                # Save configuration
                log_file.write("[INFO] Saving configuration...\n")
                save_output = connection.save_config()
                log_file.write(save_output)

                # Close connection
                connection.disconnect()
                log_file.write("[INFO] Configuration completed and connection closed.\n")

            except Exception as e:
                log_file.write(f"[ERROR] {str(e)}\n")
    except Exception as e:
        # Unable to open log file
        exit(1)

if __name__ == "__main__":
    main()
        
