#!/bin/bash

LOG_FILE=/var/log/ubicity/ubicity.log
name=ubicity
echo "$name ALL=(ALL) NOPASSWD:ALL" | (sudo su -c "EDITOR='tee' visudo -f /etc/sudoers.d/$name" >> $LOG_FILE 2>&1 )    
