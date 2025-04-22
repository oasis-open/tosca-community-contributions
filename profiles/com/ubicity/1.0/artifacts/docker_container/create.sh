#!/bin/bash

# Check mandatory inputs
if [ -z ${container_name} ]; then
    echo "Mandatory input 'container_name' is missing" >> ${LOG_FILE}
    exit 10
fi
if [ -z ${image} ]; then
    echo "Mandatory input 'image' is missing" >> ${LOG_FILE}
    exit 10
fi
if [ -z ${privileged} ]; then
    echo "Mandatory input 'privileged' is missing" >> ${LOG_FILE}
    exit 10
fi

printf "Create Docker Container %s\n" "$container_name"  >> ${LOG_FILE}

# Environment variables are optional
env_args=" "
if [ ! -z ${env} ]; then
    for key in $(jq -r 'keys[]' <<<$env)
    do
	value=$(jq -r ".$key" <<<$env)
	eval $key=\$value; export $key
	env_args+=" -e $key"
    done
else
    echo "$container_name": No environment variables >> $LOG_FILE
fi

# Add capability arguments
if [ $privileged = 'False' ]; then
    cap_args=" "
else
    cap_args=" --privileged "
fi
# cap adds and drops are optional
if [ ! -z ${cap_add} ]; then
    for cap in $(jq -r '.[]' <<<$cap_add);
    do
	cap_args+=" --cap-add $cap "
    done
else
    echo "$container_name": No caps to add >> $LOG_FILE
fi
if [ ! -z ${cap_drop} ]; then
    for cap in $(jq -r '.[]' <<<$cap_drop);
    do
	cap_args+=" --cap-drop $cap "
    done
else
    echo "$container_name": No caps to drop >> $LOG_FILE
fi

# Volumes are optional, but if volumes are configured both destination
# and either volume_mount or mount_point are required.
volume_args=""
if [ ! -z ${volume_mount} ] && [ ! -z ${mount_point} ] && [ ! -z ${destination} ]; then
    i=0
    for dst in $(jq -r '.[]' <<<$destination);
    do
	volume_id=$(jq -r ".[$i]" <<<$volume_mount)
	mnt=$(jq -r ".[$i]" <<<$mount_point)
	if [ $mnt = "null" ]; then
	    volume_args+=" -v ${volume_id}:${dst}"
	else
	    # Resolve ~ character in mount point if necessary
	    MNT="${mnt//\~/$HOME}"
	    volume_args+=" -v ${MNT}:${dst}"
	fi
	((i+=1))
    done
else
    echo "$container_name": no volumes to mount >> $LOG_FILE
fi

# Network is optional. 
if [ ! -z ${network_name} ]; then
    if [ -z ${ip_address} ] && [ -z $mac_address} ]; then
	echo IP ADDRESS and MAC ADDRESS are NULL >> $LOG_FILE
	network_args=" --network ${network_name} "
    elif [ ! -z ${ip_address} ] && [ -z ${mac_address} ]; then
	echo IP ADDRESS is $ip_address and MAC ADDRESS is NULL >> $LOG_FILE
	network_args=" --network ${network_name} --ip ${ip_address}"
    elif [ -z ${ip_address} ] && [ ! -z ${mac_address} ]; then
	echo MAC ADDRESS is $mac_address and IP ADDRESS is NULL >> $LOG_FILE
	network_args=" --network ${network_name} --mac-address ${mac_address}"
    else
	echo IP ADDRESS is $ip_address and MAC ADDRESS is $mac_address >> $LOG_FILE
	network_args=" --network ${network_name} --ip ${ip_address} --mac-address ${mac_address}"
    fi
else
    echo "$container_name": no network to connect to >> $LOG_FILE
fi

# Create a Unique ID for the container and store the container name as
# a label.
container_id=$(uuidgen)
docker run -d  \
       --name "$container_id" ${volume_args} ${network_args} ${env_args} ${cap_args} \
       --label name="$container_name" \
       "$image" >> $LOG_FILE 2>&1

# Return container details for this container
container_details=$(docker container inspect -f json "$container_id" 2>> ${LOG_FILE})
echo $container_details >> ${LOG_FILE}
jq '.[0]' <<<$container_details
