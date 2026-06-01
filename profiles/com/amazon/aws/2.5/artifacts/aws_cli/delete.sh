#!/bin/bash

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

# Unlink executables
sudo rm /usr/local/bin/aws
sudo rm /usr/local/bin/aws_completer

# Remove installation
sudo rm -rf /usr/local/aws-cli
