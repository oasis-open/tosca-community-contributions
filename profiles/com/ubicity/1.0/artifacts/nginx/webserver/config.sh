#!/bin/bash

# Delete default virtual host configuration by removing the symbolic
# link.
sudo -n rm /etc/nginx/sites-enabled/default  >> $LOG_FILE
