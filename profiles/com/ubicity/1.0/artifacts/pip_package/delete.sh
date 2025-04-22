#!/bin/bash

# LOG_FILE is set by the Executor

if [ -z "${package_names}" ]; then
	echo "Mandatory Environment Variable package_names is not set" >> ${LOG_FILE}
	exit 10
fi

# Do we run inside a virtual environment?
if [ ! -z ${virtual_env} ]; then
    # Activate
    . "${virtual_env}"/bin/activate >> ${LOG_FILE} 2>&1
fi

# Convert array of package names to strings.
PACKAGES=$(jq --raw-output '. | join(" ")' <<< ${package_names} 2>> ${LOG_FILE})
#PACKAGES=$(jq  --raw-output '. | @sh' <<< ${package_names} 2>> ${LOG_FILE})

echo Removing ${PACKAGES}  >> ${LOG_FILE} 2>&1
pip uninstall ${PACKAGES} >> ${LOG_FILE} 2>&1


