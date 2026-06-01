#!/bin/bash

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs gcp_key_file gcp_account gcp_project gcp_zone_name gcp_server_name gcp_ssh_user gcp_ssh_public_key_file

# ---------------------------------------------------------------------------
# find_image: set IMAGE_FAMILY and IMAGE_PROJECT based on OS distribution,
# version, and architecture.
#
# Supported distributions and versions:
#   ubuntu: 24.04, 22.04, 20.04
#   debian: 11, 12
#   rhel:   8, 9
#   rocky:  8, 9
#
# Supported architectures: x86_64, arm64
# ---------------------------------------------------------------------------
find_image() {
    local distribution="$1"
    local version="$2"
    local architecture="$3"
    local arch_suffix=""
    [ "$architecture" = "arm64" ] && arch_suffix="-arm64"

    case "$distribution" in
        ubuntu)
            IMAGE_PROJECT="ubuntu-os-cloud"
            case "$version" in
                "24.04") IMAGE_FAMILY="ubuntu-2404-lts${arch_suffix}" ;;
                "22.04") IMAGE_FAMILY="ubuntu-2204-lts${arch_suffix}" ;;
                "20.04") IMAGE_FAMILY="ubuntu-2004-lts${arch_suffix}" ;;
                *)       echo "Unsupported Ubuntu version: $version" >&2; exit 3 ;;
            esac
            ;;
        debian)
            IMAGE_PROJECT="debian-cloud"
            case "$version" in
                "12"|"12."*) IMAGE_FAMILY="debian-12" ;;
                "11"|"11."*) IMAGE_FAMILY="debian-11" ;;
                *)           echo "Unsupported Debian version: $version" >&2; exit 3 ;;
            esac
            ;;
        rhel)
            IMAGE_PROJECT="rhel-cloud"
            case "$version" in
                "9"|"9."*) IMAGE_FAMILY="rhel-9" ;;
                "8"|"8."*) IMAGE_FAMILY="rhel-8" ;;
                *)         echo "Unsupported RHEL version: $version" >&2; exit 3 ;;
            esac
            ;;
        rocky)
            IMAGE_PROJECT="rocky-linux-cloud"
            case "$version" in
                "9"|"9."*) IMAGE_FAMILY="rocky-linux-9${arch_suffix}" ;;
                "8"|"8."*) IMAGE_FAMILY="rocky-linux-8" ;;
                *)         echo "Unsupported Rocky Linux version: $version" >&2; exit 3 ;;
            esac
            ;;
        *)
            echo "Unsupported Linux distribution: $distribution" >&2; exit 2
            ;;
    esac
}

# ---------------------------------------------------------------------------
# mem_to_mb: convert a TOSCA scalar memory value (e.g. "1.5 GB") to MB.
# Prints the result to stdout. Exits with code 3 on error.
# ---------------------------------------------------------------------------
mem_to_mb() {
    local mem_size="$1"
    local pattern='^[[:blank:]]*([0-9]+([.][0-9]+)?)[[:blank:]]*([[:alpha:]]+)[[:blank:]]*$'
    if [[ "$mem_size" =~ $pattern ]]; then
        local value="${BASH_REMATCH[1]}"
        local units="${BASH_REMATCH[3]^^}"
    else
        echo "Unable to parse memory size: $mem_size" >&2; exit 3
    fi
    case "$units" in
        GB|GIB) bc <<< "scale=0; ($value * 1024) / 1" ;;
        MB|MIB) bc <<< "scale=0; $value / 1" ;;
        KB|KIB) bc <<< "scale=0; ($value / 1024) / 1" ;;
        TB|TIB) bc <<< "scale=0; ($value * 1024 * 1024) / 1" ;;
        B)      bc <<< "scale=0; ($value / 1048576) / 1" ;;
        *)      echo "Unsupported memory units: $units" >&2; exit 3 ;;
    esac
}

# ---------------------------------------------------------------------------
# find_machine_type: select the smallest machine type available in the zone
# that satisfies minimum CPU, memory, and architecture requirements.
# Arguments: num_cpus mem_mb architecture (x86_64 or arm64)
# Prints the machine type name to stdout. Exits with code 1 on error.
# ---------------------------------------------------------------------------
find_machine_type() {
    local cpus="$1"
    local ram_mb="$2"
    local arch="${3:-x86_64}"

    local machine_type
    machine_type=$(gcloud compute machine-types list \
        --zones="$gcp_zone_name" \
        --format=json \
        --project="$gcp_project" \
        --account="$gcp_account" \
        --quiet | \
        jq -r --argjson cpus "$cpus" --argjson ram "$ram_mb" --arg arch "$arch" '
            [.[] | select(.guestCpus >= $cpus and .memoryMb >= $ram)
                 | select(if $arch == "arm64"
                          then (.name | test("^(t2a|c4a)-"))
                          else (.name | test("^(t2a|c4a)-") | not)
                          end)]
            | sort_by([.memoryMb, .guestCpus])
            | first
            | .name')

    if [ -z "$machine_type" ] || [ "$machine_type" = "null" ]; then
        echo "ERROR: no machine type found with >= ${cpus} vCPUs, >= ${ram_mb} MB RAM, arch=${arch} in zone $gcp_zone_name" >&2
        exit 1
    fi
    echo "$machine_type"
}

# Determine the image
if [ -n "$gcp_image_family" ] && [ -n "$gcp_image_project" ]; then
    IMAGE_FAMILY="$gcp_image_family"
    IMAGE_PROJECT="$gcp_image_project"
else
    if [ "${os_type,,}" != "linux" ]; then
        echo "Unsupported operating system type: $os_type" >&2; exit 1
    fi
    find_image "${os_distribution,,}" "${os_version}" "${os_architecture:-x86_64}"
fi

echo "IMAGE_FAMILY=$IMAGE_FAMILY IMAGE_PROJECT=$IMAGE_PROJECT"

# Determine the machine type
if [ -n "$machine_type" ]; then
    MACHINE_TYPE="$machine_type"
else
    MEM_SIZE_IN_MB=$(mem_to_mb "$host_mem_size")
    MACHINE_TYPE=$(find_machine_type "$host_num_cpus" "$MEM_SIZE_IN_MB")
    [ $? -ne 0 ] && exit 1
fi

echo "MACHINE_TYPE=$MACHINE_TYPE"

SSH_KEY="${gcp_ssh_user}:$(cat "$gcp_ssh_public_key_file")"

NIC_ARGS=()
if [ -n "${gcp_subnet_names:-}" ]; then
    while IFS= read -r subnet; do
        NIC_ARGS+=(--network-interface "subnet=${subnet}")
    done < <(echo "$gcp_subnet_names" | jq -r '.[]')
fi

INSTANCE_ID=$(gcloud compute instances create "$gcp_server_name" \
    --quiet \
    "${NIC_ARGS[@]}" \
    --zone="$gcp_zone_name" \
    --project="$gcp_project" \
    --account="$gcp_account" \
    --image-family="$IMAGE_FAMILY" \
    --image-project="$IMAGE_PROJECT" \
    --machine-type="$MACHINE_TYPE" \
    --metadata="ssh-keys=${SSH_KEY}" \
    --format="value(id)")

output "instance_id: $INSTANCE_ID"

INSTANCE_INFO=$(gcloud compute instances describe "$gcp_server_name" \
    --quiet \
    --project="$gcp_project" \
    --account="$gcp_account" \
    --zone="$gcp_zone_name" \
    --format=json)

output "private_ip: $(echo "$INSTANCE_INFO" | jq -r '.networkInterfaces[0].networkIP')"
output "public_ip: $(echo "$INSTANCE_INFO" | jq -r '.networkInterfaces[0].accessConfigs[0].natIP')"
