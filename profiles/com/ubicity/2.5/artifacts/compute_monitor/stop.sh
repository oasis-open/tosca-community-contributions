#!/bin/bash

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

init_output

if [ -z "${monitor_id}" ]; then
    echo "Warning: monitor_id not provided, nothing to stop"
    exit 0
fi

# Stop the monitor
kill -9 $monitor_id || true
