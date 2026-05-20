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

require_inputs virtual_env package_names

if jq -e ' . | select(type == "array" and length == 0)' <<< "${package_names}" > /dev/null;
then
    echo "No package names specified"
    exit 10
fi

# Environment variables containing file names may include tilde
# characters, which will not get expanded (since bash does tilde
# expansion before variable expansion). Manually replace ~ if
# necessary. Note that replacement is bash-specific and not portable
# to other shells.

VIRTUAL_ENV="${virtual_env//\~/$HOME}"
# Make sure virtual environment doesn't already exist.
if [ -d "${VIRTUAL_ENV}" ]; then
    echo WARNING: virtual environment "${VIRTUAL_ENV}" already exists.
fi

# Make sure the Python venv module is installed
run_apt -y install python3-venv

# Create virtual environment
echo Creating virtual environment "${VIRTUAL_ENV}"
sudo mkdir -p "${VIRTUAL_ENV}"
# Get user name and group name to set the correct ownership
USER_NAME=$(id -un)
GROUP_NAME=$(id -gn)
sudo chown ${USER_NAME}.${GROUP_NAME} "${VIRTUAL_ENV}"
python3 -m venv "${VIRTUAL_ENV}"

# Activate and update the environment
. "${VIRTUAL_ENV}"/bin/activate
pip install -U pip

# Convert array of package names to strings.
PACKAGES=$(jq --raw-output '. | join(" ")' <<< "${package_names}")

# Install
echo "Installing ${PACKAGES}"
pip install ${PACKAGES}
