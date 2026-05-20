#!/bin/bash
#
# Common library sourced by all Azure artifact scripts.
#
# All scripts that source this file require the following environment variables:
#
#          virtual_env            path to the Python virtualenv containing the Azure CLI
#          az_credentials_file    path to a file that exports Azure service
#                                 principal variables:
#                                   AZURE_CLIENT_ID
#                                   AZURE_CLIENT_SECRET
#                                   AZURE_TENANT_ID
#                                   AZURE_SUBSCRIPTION_ID (optional)

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

expand_path() {
    echo "${1//\~/$HOME}"
}

require_inputs() {
    local missing=()
    for var_name in "$@"; do
        if [ -z "${!var_name:-}" ]; then
            missing+=("$var_name")
        fi
    done
    if [ ${#missing[@]} -gt 0 ]; then
        echo "Missing mandatory inputs: ${missing[*]}" >> "${LOG_FILE}"
        exit 10
    fi
}

# Activate virtual environment so that 'az' is on PATH.
if [ -n "${virtual_env:-}" ]; then
    VIRTUAL_ENV=$(expand_path "$virtual_env")
    . "${VIRTUAL_ENV}/bin/activate"
fi

# Source the credentials file to set AZURE_* environment variables, then
# log in as the service principal if not already authenticated.
if [ -n "${az_credentials_file:-}" ]; then
    . "$(expand_path "$az_credentials_file")"
    if ! az account show --output none >> "$LOG_FILE" 2>&1; then
        az login --service-principal \
            --username "$AZURE_CLIENT_ID" \
            --password "$AZURE_CLIENT_SECRET" \
            --tenant "$AZURE_TENANT_ID" \
            --output none >> "$LOG_FILE" 2>&1 || exit 1
    fi
fi
