#!/bin/bash

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs name node_id virtual_env monitor host

# Environment variables containing file names may include tilde
# characters, which will not get expanded (since bash does tilde
# expansion before variable expansion). Manually replace ~ if
# necessary. Note that replacement is bash-specific and not portable
# to other shells.

VIRTUAL_ENV="${virtual_env//\~/$HOME}"

# Activate and update the environment
. "${VIRTUAL_ENV}"/bin/activate

echo "Launch compute monitor script $monitor"

# Start the monitor script. Use nohup to survive SIGHUP on shell exit.
# Close fd 3 (orchestrator output pipe) in the child so the orchestrator
# gets EOF when this script exits, not when the monitor eventually terminates.
nohup python "$monitor" "$name" "$host" "$node_id" >> "$LOG_FILE" 2>&1 3>&- &

# Return the process ID of the monitor
monitor_id=$!
output "monitor_id: '${monitor_id}'"
