#!/bin/bash

# This script expects the following environment variables:
#
# linux_file_path
#
if [ -z ${linux_file_path} ]; then
    echo "linux_file_path is not set" >> /tmp/linuxfile.log
    exit 10
fi

LINUX_FILE_PATH=${linux_file_path}

rm $LINUX_FILE_PATH