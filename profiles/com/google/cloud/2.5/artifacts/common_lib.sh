#!/bin/bash
#
# Common library sourced by all GCP artifact scripts.
#
# All scripts that source this file require the following environment variables:
#
#          gcp_key_file    path to the GCP service account key file (JSON)
#          gcp_project     GCP project ID
#          gcp_account     GCP service account email

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

# Activate the GCP service account if not already in the credential store.
if [ -n "${gcp_key_file:-}" ]; then
    if ! gcloud auth list --filter="account=${gcp_account}" --format="value(account)" --quiet 2>>"$LOG_FILE" | grep -q "${gcp_account}"; then
        gcloud auth activate-service-account \
            --key-file="$(expand_path "$gcp_key_file")" \
            --quiet >> "$LOG_FILE" 2>&1 || exit 1
    fi
fi
