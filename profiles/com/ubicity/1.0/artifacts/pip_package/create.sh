#!/bin/bash

# Check mandatory inputs
if [ -z "${virtual_env}" ]; then
    echo "Mandatory Environment Variable virtual_env is not set" >> ${LOG_FILE}
    exit 10
fi

# Make sure list of package names exist and is not emptry
if [ -z "${package_names}" ]; then
    echo "Mandatory Environment Variable package_names is not set" >> ${LOG_FILE}
    exit 10
fi
if jq -e ' . | select(type == "array" and length == 0)' <<< ${package_names} > /dev/null 2>> ${LOG_FILE};
then
    echo "No package names specified" >> ${LOG_FILE}
    exit 10
fi

# LOG_FILE is set by the Executor

# Environment variables containing file names may include tilde
# characters, which will not get expanded (since bash does tilde
# expansion before variable expansion). Manually replace ~ if
# necessary. Note that replacement is bash-specific and not portable
# to other shells.

VIRTUAL_ENV="${virtual_env//\~/$HOME}"
# Make sure virtual environment doesn't already exist.
if [ -d ${VIRTUAL_ENV} ]; then
    echo WARNING: virtual environment "${VIRTUAL_ENV}" already exists. >> ${LOG_FILE}
fi

# Make sure the Python venv module is installed
sudo apt-get -y install python3-venv >> ${LOG_FILE} 2>&1

# Create virtual environment
echo Creating virtual environment "${VIRTUAL_ENV}" >> ${LOG_FILE}
sudo mkdir -p "${VIRTUAL_ENV}" >> ${LOG_FILE} 2>&1
# Get user name and group name to set the correct ownership
USER_NAME=$(id -un)
GROUP_NAME=$(id -gn)
sudo chown ${USER_NAME}.${GROUP_NAME} "${VIRTUAL_ENV}" >> ${LOG_FILE} 2>&1
python3 -m venv "${VIRTUAL_ENV}" >> ${LOG_FILE} 2>&1

# Activate and update the environment
. "${VIRTUAL_ENV}"/bin/activate >> ${LOG_FILE} 2>&1
pip install -U pip  >> ${LOG_FILE} 2>&1

# Convert array of package names to strings.
PACKAGES=$(jq --raw-output '. | join(" ")' <<< ${package_names} 2>> ${LOG_FILE})

# Install
echo Installing ${PACKAGES}  >> ${LOG_FILE} 2>&1
pip install ${PACKAGES} >> ${LOG_FILE} 2>&1


