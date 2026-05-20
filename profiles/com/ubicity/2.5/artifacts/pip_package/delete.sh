#!/bin/bash

# LOG_FILE is set by the Executor

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

init_output

require_inputs package_names

# Do we run inside a virtual environment?
if [ -n "${virtual_env}" ]; then
    VIRTUAL_ENV="${virtual_env//\~/$HOME}"
    . "${VIRTUAL_ENV}/bin/activate"
fi

# Convert array of package names to strings.
PACKAGES=$(jq --raw-output '. | join(" ")' <<< "${package_names}")

echo Removing ${PACKAGES}
pip uninstall -y ${PACKAGES}

# Remove the virtual environment directory if one was used.
if [ -n "${virtual_env}" ]; then
    echo "Removing virtual environment ${VIRTUAL_ENV}"
    sudo rm -rf "${VIRTUAL_ENV}"
fi
