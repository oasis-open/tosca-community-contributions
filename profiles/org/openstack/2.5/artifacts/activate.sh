#!/bin/bash
#
# Common library sourced by all OpenStack artifact scripts.
#
# All scripts that source this file require the following environment variables:
#
#          virtual_env       path to the Python virtualenv containing the OpenStack CLI
#          os_clouds_file    path to clouds.yaml (e.g. ~/.config/openstack/clouds.yaml)
#          os_cloud          name of the cloud entry within clouds.yaml
#          region_name       OpenStack region name

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

# Activate virtual environment. Note that environment variables
# containing file names may include tilde characters, which will not
# get expanded (since bash does tilde expansion before variable
# expansion). Manually replace ~ if necessary. Note that replacement
# is bash-specific and not portable to other shells.
require_inputs virtual_env
VIRTUAL_ENV=$(expand_path "$virtual_env")
. "${VIRTUAL_ENV}"/bin/activate >> "${LOG_FILE}" 2>&1

# Set OpenStack credentials via clouds.yaml and region via OS_REGION_NAME.
require_inputs os_clouds_file os_cloud region_name
export OS_CLIENT_CONFIG_FILE=$(expand_path "$os_clouds_file")
export OS_CLOUD="$os_cloud"
export OS_REGION_NAME="$region_name"
