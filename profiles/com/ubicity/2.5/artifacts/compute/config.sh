#!/bin/bash

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

MAX_RETRIES=30
SLEEP_SECONDS=5
LOCK_FILE="/var/lib/dpkg/lock-frontend"

# Make sure the log file exists and is writable by everyone
LOG_DIR=$(dirname "$LOG_FILE")
mkdir -p "$LOG_DIR" && touch "$LOG_FILE"
chmod a+w "$LOG_FILE"

init_output

# Install platform packages. Retry update+install together so transient
# apt-cache issues (e.g. partial mirror state leaving libonig5 marked
# "not installable") recover by re-fetching the metadata on each retry.
PLATFORM_PACKAGES="jq ca-certificates curl gnupg"
echo "Installing platform packages: ${PLATFORM_PACKAGES}"

count=0
while [ $count -lt $MAX_RETRIES ]; do
    while sudo -n fuser "$LOCK_FILE" >/dev/null 2>&1; do
        echo "dpkg lock detected. Waiting..."
        sleep $SLEEP_SECONDS
    done

    output=$(
        sudo -n DEBIAN_FRONTEND=noninteractive apt-get -y update 2>&1 &&
        sudo -n DEBIAN_FRONTEND=noninteractive apt-get -y install ${PLATFORM_PACKAGES} 2>&1
    )
    exit_code=$?

    if [ $exit_code -eq 0 ]; then
        echo "$output"
        echo "Platform packages installed successfully."
        exit 0
    fi

    echo "apt-get update+install failed (attempt $((count+1))/$MAX_RETRIES):"
    echo "$output"
    sleep $SLEEP_SECONDS
    count=$((count+1))
done

echo "Max retries reached. Installation failed."
exit 1
