#!/bin/bash
#
# Common library

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

# Parse JSON env vars and convert to YAML
parse_env_vars() {
    local env_json="$1"
    
    # Check if env_json is empty or just '{}'
    if [ "$env_json" = "{}" ] || [ -z "$env_json" ]; then
        echo ""
        return
    fi
    
    # Parse JSON and convert to YAML env format
    echo "$env_json" | jq -r '
    	 .[] |
	 "- name: \(.name)\n  value: \"\(.value|tostring)\""
	 '
}

