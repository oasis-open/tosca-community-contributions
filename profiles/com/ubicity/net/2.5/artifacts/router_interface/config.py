# 
# Configure Cisco Network Interface
#
__author__ = "Chris Lauwers"
__copyright__ = "Copyright (c) 2025, Ubicity Corp."
__email__ = "lauwers@ubicity.com"

import os
from netmiko import ConnectHandler

# Open log file in append mode
log_file_name = os.environ['LOG_FILE']

def main():
    try:
        with open(log_file_name, "a") as log_file:
            # Check mandatory inputs
            if not 'management_ip' in os.environ or not os.environ['management_ip']:
                log_file.write("Mandatory input 'management_ip' is missing\n")
            if not 'username' in os.environ or not os.environ['username']:
                log_file.write("Mandatory input 'username' is missing\n")
            if not 'password' in os.environ or not os.environ['password']:
                log_file.write("Mandatory input 'password' is missing\n")
            if not 'enable_password' in os.environ or not os.environ['enable_password']:
                log_file.write("Mandatory input 'enable_password' is missing\n")
            if not 'name' in os.environ or not os.environ['name']:
                log_file.write("Mandatory input 'name' is missing\n")
            if not 'ip_address' in os.environ or not os.environ['ip_address']:
                log_file.write("Mandatory input 'ip_address' is missing\n")
            if not 'subnet_mask' in os.environ or not os.environ['subnet_mask']:
                log_file.write("Mandatory input 'subnet_mask' is missing\n")

            # Device configuration
            device = {
                "device_type": "cisco_ios",
                "host": os.environ['management_ip'],
                "username": os.environ['username'],
                "password": os.environ['password'],
                "port": 22, 
                "secret": os.environ['enable_password'],
            }

            # Commands to configure the interface
            commands = [
                f"interface {os.environ['name']}",
                f"ip address {os.environ['ip_address']} {os.environ['subnet_mask']}",
                "no shutdown",
                "exit",
            ]

            # Establish SSH connection
            log_file.write("[INFO] Connecting to device...\n")
            connection = ConnectHandler(**device)

            # Enter enable mode
            connection.enable()

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

if __name__ == "__main__":
    main()
        
