#!/bin/bash

# Check mandatory inputs
if [ -z ${web_site_name} ]; then
    echo "Mandatory input 'web_site_name' is missing" >> ${LOG_FILE}
    exit 10
fi

# Disable virtual Host configuration for 'web_site' by
# removing the symbolic link.
cd /etc/nginx/sites-enabled/
sudo -n rm ${web_site_name}  >> $LOG_FILE

# Delete web site content
cd /var/www
sudo -n rm -rf ${web_site_name}  >> $LOG_FILE

# Restart nginx
sudo systemctl restart nginx >> $LOG_FILE
