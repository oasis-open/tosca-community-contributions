#!/bin/bash

if [ -z ${name} ]; then
    echo "Mandatory input 'name' is missing" >> ${LOG_FILE}
    exit 10
fi
if [ -z ${node_id} ]; then
    echo "Mandatory input 'node_id' is missing" >> ${LOG_FILE}
    exit 10
fi
if [ -z ${virtual_env} ]; then
    echo "Mandatory input 'virtual_env' is missing" >> ${LOG_FILE}
    exit 10
fi
if [ -z ${monitor} ]; then
    echo "Mandatory input 'monitor' is missing" >> ${LOG_FILE}
    exit 10
fi
if [ -z ${host} ]; then
    echo "Mandatory input 'host' is missing" >> ${LOG_FILE}
    exit 10
fi

# Environment variables containing file names may include tilde
# characters, which will not get expanded (since bash does tilde
# expansion before variable expansion). Manually replace ~ if
# necessary. Note that replacement is bash-specific and not portable
# to other shells.

VIRTUAL_ENV="${virtual_env//\~/$HOME}"

# Activate and update the environment
. "${VIRTUAL_ENV}"/bin/activate >> ${LOG_FILE} 2>&1

echo Launch compute monitor script $monitor >> $LOG_FILE

# Start the monitor script
python $monitor $name $host $node_id >> $LOG_FILE 2>&1 &

# Return the process ID of the monitor
monitor_id=$(echo $!)
echo monitor_id: \'$monitor_id\'
