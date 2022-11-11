#!/bin/bash

# This script expects the following environment variables:
#
# linux_file_path
# linux_file_content which must be a single string
#

LOG_FILE=/tmp/linuxfile.log

if [ -z ${linux_file_path} ]; then
    echo "linux_file_path is not set" >> $LOG_FILE
    exit 10
fi

if [ -z ${linux_file_content} ]; then
    echo "linux_file_content is not set" >> $LOG_FILE
    exit 10
fi

LINUX_FILE_PATH=${linux_file_path}
LINUX_FILE_CONTENT=${linux_file_content}

# create the file
touch $LINUX_FILE_PATH
echo ${LINUX_FILE_CONTENT} > $LINUX_FILE_PATH

#get an attribute of the file as a single string
LINUX_FILE_MTIME=$(stat --format=%y ${LINUX_FILE_PATH} | sed 's/\s/_/g') 2>> $LOG_FILE

output() {
    echo $@ 2>&1
}

output  "linux_file_mtime: $LINUX_FILE_MTIME"