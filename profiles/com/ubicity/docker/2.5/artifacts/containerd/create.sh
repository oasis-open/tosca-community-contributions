#!/bin/bash
set -eo pipefail
#
# This script installs containerd
#
#    LOG_FILE (Set by the Executor)

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
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

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo -n gpg --batch --no-tty --yes --dearmor -o /usr/share/keyrings/docker.gpg
sudo -n chmod a+r /usr/share/keyrings/docker.gpg

# Add Docker apt repository.
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo -n tee /etc/apt/sources.list.d/docker.list

## Install Docker CE.
run_apt update
run_apt install -y containerd.io
