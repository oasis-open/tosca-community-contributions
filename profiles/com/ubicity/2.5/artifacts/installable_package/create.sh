#!/bin/bash
set -eo pipefail

# Each line in a sources.list file has the following format:
#
#      deb [<options>] <repository_url> <suite> <components>
#
# If a "/" is specified as the value for the "suite", apt will ignore
# the "suite" and "components" values and use the "repository_url"
# as-is.
#
# If the value for "suite" is not specified, the code name for the
# Linux release will be used (retrieved using the lsb_release
# command).
#
# If the value for "components" is not specified the default value
# "main" will be used.
#

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

require_inputs name package_names

# Make sure list of package names is not empty
if jq -e '. | select(type == "array" and length == 0)' <<< "${package_names}" > /dev/null; then
    echo "No package names specified"
    exit 10
fi

# Do we need to add the repository?
if [ ! -z "${repository+x}" ] && [ ! -z "${repository_key+x}" ]; then
    # Figure out suite and components
    if [ -z "${suite+x}" ]; then
	suite=$(lsb_release -cs)
    elif [ "$suite" == "/" ]; then
	components=""
    fi
    if [ -z "${components+x}" ]; then
	components="main"
    fi
    # Add the component's GPG key
    curl -fsSL "$repository_key" | sudo -n gpg --yes --dearmor -o "/usr/share/keyrings/$name.gpg"
    sudo -n chmod a+r "/usr/share/keyrings/$name.gpg"
    # Add the component's apt repository.
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/$name.gpg] $repository $suite $components" | \
	sudo -n tee "/etc/apt/sources.list.d/$name.list"
    run_apt update
fi

# Convert array of package names to strings.
PACKAGES=$(jq --raw-output '. | join(" ")' <<< "${package_names}")

echo "Installing ${PACKAGES}"
run_apt install -y \
    -o Dpkg::Options::="--force-confdef" \
    -o Dpkg::Options::="--force-confold" \
    $PACKAGES
