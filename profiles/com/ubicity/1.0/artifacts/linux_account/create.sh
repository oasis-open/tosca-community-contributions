#!/bin/bash

# Make sure we have an account name
if [ -z "${name}" ]; then
    echo "Mandatory input 'name' is missing" >> ${LOG_FILE}
    exit 10
fi

# Initialize command line arguments
ARGS=""

# Is this a system account?
if [ ! -z "${system_user+x}" ] && [ $system_user = 'True' ]; then
    ARGS+='-r '
fi

# Check if list of group names exists and is not emptry
if [ ! -z "${supplementary_groups}" ]; then
    if jq -e ' . | select(type == "array" and length > 0)' <<< ${supplementary_groups} > /dev/null 2>> ${LOG_FILE};
    then
	# Convert array of group names to string
	SUPPLEMENTARY_GROUPS=$(jq --raw-output '. | join(",")' <<< ${supplementary_groups} 2>> ${LOG_FILE})
	ARGS+="-G $SUPPLEMENTARY_GROUPS "
	# Is this a "sudo without password" user?
	if jq -e '.|any(. == "sudo")'  <<< ${supplementary_groups} > /dev/null 2>> ${LOG_FILE}; then
	    if [ ! -z "${sudo_no_password+x}" ] && [ $sudo_no_password = 'True' ]; then
		SUDOER=Yes
	    fi
	fi
    fi
fi

# Define home directory if necessary
if [ ! -z "${home_directory}" ]; then
    ARGS+="-d $home_directory -m "
fi

# Define shell if necessary
if [ ! -z "${shell}" ]; then
    ARGS+="-s $shell "
fi

# Create user
sudo useradd $ARGS $name >> $LOG_FILE  2>&1

# Make sudoer if necessary
if [ ! -z "${SUDOER}" ]; then
    echo "$name ALL=(ALL) NOPASSWD:ALL" | (sudo su -c "EDITOR='tee' visudo -f /etc/sudoers.d/$name" >> /dev/null 2>> $LOG_FILE )    
fi

# Return user id and group name
USER_ID=$(id -u $name)
GROUP_NAME=$(id -gn $name)
echo uid: $USER_ID
echo group_name: $GROUP_NAME
