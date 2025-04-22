#!/bin/bash

# LOG_FILE is set by the Executor

if [ -z ${package_names} ]; then
	echo "Mandatory input 'package_names' is missing" >> ${LOG_FILE}
	exit 10
fi

# Convert array of package names to strings.
PACKAGES=$(jq --raw-output '. | join(" ")' <<< ${package_names} 2>> ${LOG_FILE})

echo Removing ${PACKAGES}  >> ${LOG_FILE} 2>&1
sudo -n apt-get -y remove --purge ${PACKAGES} >> ${LOG_FILE} 2>&1


