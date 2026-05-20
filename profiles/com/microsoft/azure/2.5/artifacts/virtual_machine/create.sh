#!/bin/bash

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs az_credentials_file az_group_name az_instance_name \
               az_ssh_user az_ssh_public_key_file az_region_name

# ---------------------------------------------------------------------------
# find_image: set AZURE_IMAGE based on OS distribution, version,
# and architecture.
#
# Supported distributions and versions:
#   ubuntu: 20.04, 22.04, 24.04
#   debian: 11, 12
#   rhel:   8, 9
#
# Supported architectures: x86_64, arm64
# ---------------------------------------------------------------------------
find_image() {
    local distribution="$1"
    local version="$2"
    local architecture="$3"

    case "$distribution" in
        ubuntu)
            case "$version" in
                "24.04") AZURE_IMAGE="Ubuntu2404" ;;
                "22.04") AZURE_IMAGE="Ubuntu2204" ;;
                "20.04") AZURE_IMAGE="Ubuntu2004" ;;
                *)       echo "Unsupported Ubuntu version: $version" >&2; exit 3 ;;
            esac
            ;;
        debian)
            case "$version" in
                "12"|"12."*) AZURE_IMAGE="Debian12" ;;
                "11"|"11."*) AZURE_IMAGE="Debian11" ;;
                *)           echo "Unsupported Debian version: $version" >&2; exit 3 ;;
            esac
            ;;
        rhel)
            case "$version" in
                "9"|"9."*) AZURE_IMAGE="RedHat:RHEL:9-lvm:latest" ;;
                "8"|"8."*) AZURE_IMAGE="RedHat:RHEL:8-lvm:latest" ;;
                *)         echo "Unsupported RHEL version: $version" >&2; exit 3 ;;
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
# find_vm_size: select the smallest Azure VM size in the region that
# satisfies minimum CPU, memory, and architecture requirements.
# Arguments: num_cpus mem_mb architecture (x86_64 or arm64)
# Prints the VM size name to stdout. Exits with code 1 on error.
# ---------------------------------------------------------------------------
find_vm_size() {
    local cpus="$1"
    local ram_mb="$2"
    local arch="${3:-x86_64}"

    local az_arch="x64"
    [ "$arch" = "arm64" ] && az_arch="Arm64"

    local vm_size
    vm_size=$(az vm list-skus \
        --location "$az_region_name" \
        --resource-type virtualMachines \
        --output json | \
        jq -r --argjson cpus "$cpus" --argjson ram "$ram_mb" --arg arch "$az_arch" '
            [.[]
             | select(.restrictions | length == 0)
             | select(any(.capabilities[]; .name == "CpuArchitectureType" and .value == $arch))
             | {name: .name,
                vcpus: ([.capabilities[] | select(.name == "vCPUs") | .value | tonumber] | first),
                ram_mb: ([.capabilities[] | select(.name == "MemoryGB") | .value | tonumber * 1024] | first)}
             | select(.vcpus >= $cpus and .ram_mb >= $ram)]
            | sort_by([.ram_mb, .vcpus])
            | first
            | .name')

    if [ -z "$vm_size" ] || [ "$vm_size" = "null" ]; then
        echo "ERROR: no VM size found with >= ${cpus} vCPUs, >= ${ram_mb} MB RAM, arch=${arch} in $az_region_name" >&2
        exit 1
    fi
    echo "$vm_size"
}

# Determine the image
if [ -n "${az_image:-}" ]; then
    AZURE_IMAGE="$az_image"
else
    if [ "${os_type,,}" != "linux" ]; then
        echo "Unsupported operating system type: $os_type" >&2; exit 1
    fi
    find_image "${os_distribution,,}" "${os_version}" "${os_architecture:-x86_64}"
fi

echo "IMAGE=$AZURE_IMAGE"

# Determine the VM size
if [ -n "${az_vm_size:-}" ]; then
    VM_SIZE="$az_vm_size"
else
    MEM_SIZE_IN_MB=$(mem_to_mb "$host_mem_size")
    VM_SIZE=$(find_vm_size "$host_num_cpus" "$MEM_SIZE_IN_MB" "${os_architecture:-x86_64}")
    [ $? -ne 0 ] && exit 1
fi

echo "VM_SIZE=$VM_SIZE"

ARGS=(
    --resource-group "$az_group_name"
    --image "$AZURE_IMAGE"
    --size "$VM_SIZE"
    --admin-username "$az_ssh_user"
    --authentication-type ssh
    --ssh-key-values "@${az_ssh_public_key_file}"
    --name "$az_instance_name"
)

[ -n "${az_zone:-}" ] && ARGS+=(--zone "$az_zone")

if [ -n "${az_network_interfaces:-}" ]; then
    while IFS= read -r nic; do
        NIC_NAMES+=("$nic")
    done < <(echo "$az_network_interfaces" | jq -r '.[]')
    ARGS+=(--nics "${NIC_NAMES[@]}")
fi

VM_INFO=$(az vm create "${ARGS[@]}" --output json)

output "private_ip: $(echo "$VM_INFO" | jq -r '.privateIpAddress')"
output "public_ip: $(echo "$VM_INFO" | jq -r '.publicIpAddress')"
