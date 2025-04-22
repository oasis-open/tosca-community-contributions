#!/bin/bash

# Check mandatory inputs
if [ ! -z ${mount_point} ]; then
    # This is an anonymous volume.
    VOLUME_TYPE="anonymous"
else
    VOLUME_TYPE="named"
    # Named volumes must define a name
    if [ -z ${volume_name} ]; then
	echo "Mandatory input 'volume_name' is missing" >> ${LOG_FILE}
	exit 10
    fi
fi
if [ -z ${driver} ]; then
    echo "Mandatory input 'driver' is missing" >> ${LOG_FILE}
    exit 10
fi

if [ $VOLUME_TYPE == "anonymous" ]; then
    # Resolve ~ character in mount point if necessary
    MOUNT_POINT="${mount_point//\~/$HOME}"

    printf "Create anonymous Docker Volume on %s\n" "$MOUNT_POINT"  >> ${LOG_FILE}

    # Make sure mount point exists
    mkdir -p $MOUNT_POINT  >> $LOG_FILE 2>&1

    # Return volume details
    echo "Name: "
    echo "Mountpoint: $mount_point"

else
    # Create a Unique ID for the volume and Store the volume name as a
    # label.
    volume_id=$(uuidgen)
    docker volume create \
	   --label name="$volume_name" \
	   --driver "$driver" \
	   "$volume_id" >> $LOG_FILE 2>&1

    # Return volume details for this volume
    volume_details=$(docker volume inspect -f json "$volume_id" 2>> ${LOG_FILE})
    jq '.[0]' <<<$volume_details

fi
