#!/bin/bash

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

# Nothing to do if aws is already installed
if [ -x /usr/local/bin/aws ]; then
    echo "Aws command line is already installed"
    exit
fi

# Download the aws package
cd /tmp
sudo rm -rf aws awscliv2.zip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Unpack.
unzip awscliv2.zip

# Install. Run with the --update flag in case aws was already installed
sudo ./aws/install --update
