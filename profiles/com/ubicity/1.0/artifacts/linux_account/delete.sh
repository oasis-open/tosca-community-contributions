#!/bin/bash

# Make sure we have an account name
if [ -z "${name}" ]; then
    echo "Mandatory input 'name' is missing" >> ${LOG_FILE}
    exit 10
fi

# delete user
sudo userdel -f -r $name >> $LOG_FILE  2>&1
sudo rm -rf /etc/sudoers.d/$name >> $LOG_FILE  2>&1
