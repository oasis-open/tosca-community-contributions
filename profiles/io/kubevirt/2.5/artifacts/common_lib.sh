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

    local cmd="kubectl --kubeconfig=${kubeconfig_expanded}"

    if [ -n "${context}" ]; then
        echo "Using context: ${context}" >&2
        cmd="${cmd} --context=${context}"
    fi

    echo "${cmd}"
}

init_output() {
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
