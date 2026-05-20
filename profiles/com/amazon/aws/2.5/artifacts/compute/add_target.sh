#!/bin/bash

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

init_output

# Check whether mac_address input is provided
if [ -z "${mac_address}" ]; then
    output "interface_name: "
    exit 0
fi

# Case-insensitive comparison
interfaces=$(ip -o -j link)
interface_name=$(jq -r --arg mac "${mac_address,,}" '.[] | select((.address|ascii_downcase)==$mac) | .ifname' <<< "$interfaces")

output "interface_name: $interface_name"
