#!/bin/bash

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. $HERE/../common_lib.sh

init_output

# Only proceed if there is a key file name
if [ -n "${key_file}" ]; then
    rm -rf "${key_file}"
fi
if [ -n "${public_key_file}" ]; then
    rm -rf "${public_key_file}"
fi
