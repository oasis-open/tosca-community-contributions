#!/bin/bash

# Exit on first error
set -e

# Set environment variables
HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. $HERE/env.sh

EXAMPLES=(
    "online_boutique"
)

for i in ${EXAMPLES[@]}; do
    validate ${EXAMPLES_DIR}/$i
done


