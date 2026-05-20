#!/bin/bash

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

init_output

# Schedule delayed reboot in a new session to avoid SSH connection errors
# when executed remotely.
echo "Scheduling reboot in 5 seconds..."
setsid nohup bash -c 'sleep 5 && sudo -n reboot' >/dev/null 2>&1 &
disown
