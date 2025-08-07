#!/bin/bash

# This script creates a Mermaid class diagram for the node types
# defined in a TOSCA file.

# This script requires 'yq' 
if ! command -v yq >/dev/null 2>&1; then
    echo "This script requires 'yq' which can be installed as follows:"
    echo "    sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq"
    echo "    sudo chmod +x /usr/local/bin/yq"
    exit
fi

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
	*)
	    if [ ! -z ${TOSCA_FILE} ]; then
		echo "Only one TOSCA file argument allowed"
		exit 2
	    fi
	    TOSCA_FILE="$1" # save positional arg
	    shift # past argument
	    ;;
    esac
done

if [ -z ${TOSCA_FILE} ]; then
    echo "Usage: mermaid.sh tosca_file"
    exit 3
fi

if [ ! -f ${TOSCA_FILE} ]; then
    echo "TOSCA file ${TOSCA_FILE} does not exist"
    exit 4
fi

# Output the class diagram
echo classDiagram
yq '
    .node_types 
    | to_entries
    | [
    	# First, output top-level classes
	(
	  map(select(.value.derived_from == null)) 
	  | .[]
	  | "    class \(.key)"
	),
	# Next, output derived classes"
	(
	  map(select(.value.derived_from))
	  | .[]
	  | "    \(.value.derived_from) <|-- \(.key)"
	)
      ]
    | .[]
' $TOSCA_FILE
