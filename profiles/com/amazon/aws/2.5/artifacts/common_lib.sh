#!/bin/bash
#
# Common library

# Expand tilde in a path. Variables containing file names may include
# tilde characters, which will not get expanded (since bash does tilde
# expansion before variable expansion). Note that replacement is
# bash-specific and not portable to other shells.
expand_path() {
    echo "${1//\~/$HOME}"
}

# Build a kubectl command that uses the specified kubeconfig file and
# context
build_kubectl_cmd() {
    local kubeconfig="$1"
    local context="$2"
    local kubeconfig_expanded
    kubeconfig_expanded=$(expand_path "$kubeconfig")

    # Build kubectl command
    local cmd="kubectl --kubeconfig=${kubeconfig_expanded}"

    # Add context if provided
    if [ -n "${context}" ]; then
        echo "Using context: ${context}" >&2
        cmd="${cmd} --context=${context}"
    fi

    echo "${cmd}"
}

# ---------------------------------------------------------------------------
# init_aws_credentials: export AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
# by reading the given credentials file for the specified profile.
# Arguments: credentials_file [profile]   (profile defaults to "default")
# Exits with code 1 if the credentials cannot be found.
# ---------------------------------------------------------------------------
init_aws_credentials() {
    local cred_file
    cred_file=$(expand_path "$1")
    local profile="${2:-default}"

    export AWS_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY
    AWS_ACCESS_KEY_ID=$(AWS_SHARED_CREDENTIALS_FILE="$cred_file" aws configure get aws_access_key_id --profile "$profile") || {
        echo "ERROR: could not read aws_access_key_id for profile [$profile] from $cred_file" >&2; exit 1
    }
    AWS_SECRET_ACCESS_KEY=$(AWS_SHARED_CREDENTIALS_FILE="$cred_file" aws configure get aws_secret_access_key --profile "$profile") || {
        echo "ERROR: could not read aws_secret_access_key for profile [$profile] from $cred_file" >&2; exit 1
    }
}

# Apply AWS credentials automatically when this library is sourced.
# aws_credentials_file is set by the orchestrator as an environment variable.
if [ -n "${aws_credentials_file:-}" ]; then
    init_aws_credentials "$aws_credentials_file" "${aws_profile:-default}"
fi

init_output() {
    # Save original stdout and redirect to log file
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() {
	echo "$@" >&3
    }
}

# Validate multiple mandatory inputs at once
# Usage: require_inputs name image namespace
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

