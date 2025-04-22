#!/bin/bash

#
# Start Minikube Cluster
#

# Make sure name exist and is not emptry
if [ -z "${name}" ]; then
    echo "Mandatory Environment Variable name is not set" >> ${LOG_FILE}
    exit 10
fi
# Make sure public address exist and is not emptry
if [ -z "${public_address}" ]; then
    echo "Mandatory Environment Variable public_address is not set" >> ${LOG_FILE}
    exit 10
fi

# Switch to minikube user and start minikube
#sudo su - miniuser -c "minikube start --profile $name --apiserver-ips $public_address" >> ${LOG_FILE} 2>&1 
sudo -i -u miniuser minikube start --profile $name --apiserver-ips $public_address >> ${LOG_FILE} 2>&1 

# Keys and certificates are stored in /home/miniusers/.minikube/profiles/<name>
