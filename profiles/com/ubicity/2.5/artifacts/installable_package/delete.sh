#!/bin/bash

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

require_inputs() {
    local missing=()
    for var_name in "$@"; do
        local var_value="${!var_name:-}"
        if [ -z "$var_value" ]; then
            missing+=("$var_name")
        fi
    done
    if [ ${#missing[@]} -gt 0 ]; then
        echo "Missing mandatory inputs: ${missing[*]}"
        exit 10
    fi
}

MAX_RETRIES=30
SLEEP_SECONDS=5
LOCK_FILE="/var/lib/dpkg/lock-frontend"

# Run an apt-get subcommand, waiting for the dpkg lock and retrying on
# transient failures (e.g. unattended-upgrades holding the lock).
run_apt() {
    local count=0
    while [ $count -lt $MAX_RETRIES ]; do
        while sudo -n fuser "$LOCK_FILE" >/dev/null 2>&1; do
            echo "dpkg lock detected. Waiting..."
            sleep $SLEEP_SECONDS
        done

        local output exit_code=0
        output=$(sudo -n DEBIAN_FRONTEND=noninteractive apt-get "$@" 2>&1) || exit_code=$?

        if [ $exit_code -eq 0 ]; then
            echo "$output"
            return 0
        fi

        echo "apt-get $1 failed (attempt $((count+1))/$MAX_RETRIES):"
        echo "$output"
        sleep $SLEEP_SECONDS
        count=$((count+1))
    done

    echo "Max retries reached. apt-get $1 failed."
    return 1
}

init_output

require_inputs package_names

# Convert array of package names to strings.
PACKAGES=$(jq --raw-output '. | join(" ")' <<< "${package_names}")

echo "Removing ${PACKAGES}"
run_apt -y remove --purge $PACKAGES

# Cleanup orphaned dependencies
run_apt -q -y autoremove
