#!/bin/bash

# Make sure output file directory exists
OUTPUT_DIR=/tmp/ubicity/logs
mkdir -p $OUTPUT_DIR

echo $1

cat > ./tutorial/TOSCA.meta <<EOF
CSAR-Version: 2.0
Created-By: Ubicity Corp.
Entry-Definitions: $1
EOF

ubicity catalog validate tutorial > $OUTPUT_DIR/$1.log

