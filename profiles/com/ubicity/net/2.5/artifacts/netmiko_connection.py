# 
# Establish and use netmiko connections
#
__author__ = "Chris Lauwers"
__copyright__ = "Copyright (c) 2025, Ubicity Corp."
__email__ = "lauwers@ubicity.com"

# Environment variables
import os

# Decoding
import json
import base64

# Netmiko
from netmiko import ConnectHandler

def establish(log_file):
    # Make sure we have a device to connect to
    if not 'management_ip' in os.environ or not os.environ['management_ip']:
        raise Exception(f"No management IP address provided")

    # Parse credentials and get password file
    try:
        admin_user = os.environ['admin_user']
        log_file.write(f"JSON: {admin_user}\n")
        user = json.loads(admin_user)
        log_file.write(f"PY: {str(user)}\n")
    except KeyError:
        raise Exception(f"No credentials provided")
    if not 'user_name' in user or not user['user_name']:
        raise Exception(f"No user name provided")
    if not 'password_file' in user or not user['password_file']:
        raise Exception(f"No password file provided")

    # Read passwords from passwords file. Expand '~' in file names if
    # necessary
    password_file = os.path.expanduser(user['password_file'])
    try:
        with open(password_file,'r') as f:
            auth_string = base64.b64decode(f.readline().strip()).decode()
            auth_parts = auth_string.split(':')
            if len(auth_parts) != 3:
                raise Exception(f"{password_file} contains improperly-formatted credentials")
            password = auth_parts[1]
            secret = auth_parts[2]
    except IOError as e:
        raise Exception(f"Unable to read password file {password_file}: {str(e)}")

    # Device configuration
    device = {
        "device_type": "cisco_ios",
        "host": os.environ['management_ip'],
        "username": user['user_name'],
        "password": password,
        "port": 22, 
        "secret": secret,
    }

    # Establish SSH connection and enter enable mode
    connection = ConnectHandler(**device)
    connection.enable()

    # All done
    return connection
