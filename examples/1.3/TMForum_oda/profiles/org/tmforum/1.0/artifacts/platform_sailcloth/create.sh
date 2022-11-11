#!/bin/bash

#create a file structure which emulates and ODA component on canvas

# This script expects the following environment variables:
#
#          oda_sailcloth: a directory where the emulator files are stored
# The following are optional
#           oda_sailcloth_fresh: when set the directory is cleared 


DEBUG=0

if [ $DEBUG -eq 1 ]; then
    echo "in debug mode"
    oda_sailcloth="/tmp/sailcloth"
    oda_sailcloth_fresh="True"
fi

#Create a directory for the instance
PLATFORM_DIR=$oda_sailcloth
if [ ! -d "$PLATFORM_DIR" ]; then
    mkdir -p $PLATFORM_DIR
else
    if [ ${oda_sailcloth_fresh} == 'True' ]; then
        # empty the directory of yaml files (which is all that should be in there) and empty directories
        find $PLATFORM_DIR -name *.yaml -exec rm {} \;
        find $PLATFORM_DIR -depth -type d -exec rm -d {} \;
    fi
fi



