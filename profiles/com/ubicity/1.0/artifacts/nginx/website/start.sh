#!/bin/bash

# Check mandatory inputs
if [ -z ${web_site_name} ]; then
    echo "Mandatory input 'web_site_name' is missing" >> ${LOG_FILE}
    exit 10
fi

# Enable virtual Host configuration for 'web_site' by
# creating a symbolic link.
cd /etc/nginx/sites-enabled/
sudo -n ln -s ../sites-available/${web_site_name} >> $LOG_FILE

# Restart nginx
sudo systemctl restart nginx >> $LOG_FILE


