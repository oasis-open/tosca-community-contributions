#!/bin/bash

# Each line in a sources.list file has the following format:
#
#      deb [<options>] <repository_url> <suite> <components>
#
# If a "/" is specified as the value for the "suite", apt will ignore
# the "suite" and "components" values and use the "repository_url"
# as-is.
#
# If the value for "suite" is not specified, the code name for the
# Linux release will be used (retrieved using the lsb_release
# command).
#
# If the value for "components" is not specified the default value
# "main" will be used.
#
# Make sure component name exists and is not emptry
if [ -z "${name}" ]; then
    echo "Mandatory input 'name' is missing" >> ${LOG_FILE}
    exit 10
fi
# Make sure list of package names exist and is not emptry
if [ -z "${package_names}" ]; then
    echo "Mandatory input 'package_names' is missing" >> ${LOG_FILE}
    exit 10
fi
if jq -e ' . | select(type == "array" and length == 0)' <<< ${package_names} > /dev/null 2>> ${LOG_FILE};
then
    echo "No package names specified" >> ${LOG_FILE}
    exit 10
fi

# Do we need to add the repository?
if [ ! -z ${repository+x} ] && [ ! -z ${repository_key+x} ]; then
    # Figure out suite and components
    if [ -z ${suite+x} ]; then
	suite=$(lsb_release -cs)
    elif [ "$suite" == "/" ]; then
	components=""
    fi
    if [ -z ${components+x} ]; then
	components="main"
    fi
    # Add the component's GPG key
    curl -fsSL $repository_key 2>> ${LOG_FILE} | sudo -n gpg --yes --dearmor -o /usr/share/keyrings/$name.gpg >> ${LOG_FILE} 2>&1
    sudo -n chmod a+r /usr/share/keyrings/$name.gpg >> ${LOG_FILE} 2>&1
    # Add the component's apt repository.
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/$name.gpg] $repository $suite $components" | \
	sudo -n tee /etc/apt/sources.list.d/$name.list >> ${LOG_FILE} 2>&1
    sudo -n apt-get update >> ${LOG_FILE} 2>&1
fi

# Convert array of package names to strings.
PACKAGES=$(jq --raw-output '. | join(" ")' <<< ${package_names} 2>> ${LOG_FILE})

# Install
echo Installing ${PACKAGES}  >> ${LOG_FILE} 2>&1
sudo -n apt-get -y install ${PACKAGES} >> ${LOG_FILE} 2>&1
