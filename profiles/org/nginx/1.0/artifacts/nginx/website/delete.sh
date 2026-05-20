#!/bin/bash

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

require_inputs() {
    local missing=()
    for var_name in "$@"; do
        local var_value="${!var_name:-}"
        if [ -z "$var_value" ]; then
            missing+=("$var_name")
        fi
    done
    if [ ${#missing[@]} -gt 0 ]; then
        echo "Missing mandatory inputs: ${missing[*]}"
        exit 10
    fi
}

init_output

require_inputs web_site_name

# Disable virtual Host configuration for 'web_site' by
# removing the symbolic link.
cd /etc/nginx/sites-enabled/
sudo -n rm ${web_site_name}

# Delete web site content
cd /var/www
sudo -n rm -rf ${web_site_name}

# Restart nginx
sudo systemctl restart nginx
