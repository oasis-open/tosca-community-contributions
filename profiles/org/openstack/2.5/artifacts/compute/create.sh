#!/bin/bash

# Openstack automatically starts servers when they are created. This
# script therefore just checks to see if the server is up and running
# ('ACTIVE')
#
# Mandatory Environment Variables:
#
#          key_name
#
# Optional Environment Variables:
#
#          image_id            (if provided, used directly as the image ID)
#          os_architecture     (mandatory if image_id not provided; x86_64, arm64)
#          os_type             (mandatory if image_id not provided; linux)
#          os_distribution     (mandatory if image_id not provided; ubuntu, fedora, rhel, debian)
#          os_version          (mandatory if image_id not provided; ubuntu: 24.04/22.04, fedora: 40/41, rhel: 8/9, debian: 11/12)
#          flavor              (if provided, used directly as the flavor name)
#          host_num_cpus       (mandatory if flavor not provided)
#          host_mem_size       (mandatory if flavor not provided)
#          server_name
#          host_cpu_frequency
#          host_disk_size
#          ports
#
# LOG_FILE is set by the Executor

# Activate virtual environment and set authentication variables.
HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../activate.sh"

init_output

require_inputs key_name

# ---------------------------------------------------------------------------
# find_image_id: find the OpenStack image ID for a given distribution,
# version, and architecture by searching image names.
# Arguments: distribution version architecture
# Prints the image ID to stdout. Exits with code 1, 2, or 3 on error.
#
# Supported distributions and versions:
#   ubuntu: 24.04, 22.04
#   fedora: 40, 41
#   rhel:   8, 9
#   debian: 11, 12
#
# Supported architectures: x86_64, arm64
# ---------------------------------------------------------------------------
find_image_id() {
    local distribution="$1"
    local version="$2"
    local architecture="$3"

    local distro normalized_version

    case "$distribution" in
        "ubuntu" )
            distro=ubuntu
            case "$version" in
                "24.04"|"22.04" ) normalized_version="$version" ;;
                * ) echo "Unsupported Ubuntu version $version" >&2; exit 3 ;;
            esac
            ;;
        "fedora" )
            distro=fedora
            case "$version" in
                "40"|"41" ) normalized_version="$version" ;;
                * ) echo "Unsupported Fedora version $version" >&2; exit 3 ;;
            esac
            ;;
        "rhel" )
            distro=rhel
            case "$version" in
                "8"|"8."* ) normalized_version=8 ;;
                "9"|"9."* ) normalized_version=9 ;;
                * ) echo "Unsupported RHEL version $version" >&2; exit 3 ;;
            esac
            ;;
        "debian" )
            distro=debian
            case "$version" in
                "11"|"11."* ) normalized_version=11 ;;
                "12"|"12."* ) normalized_version=12 ;;
                * ) echo "Unsupported Debian version $version" >&2; exit 3 ;;
            esac
            ;;
        * )
            echo "Unsupported Linux distribution: $distribution" >&2; exit 2
            ;;
    esac

    # Map architecture to common image name conventions
    local arch_pattern
    case "$architecture" in
        x86_64 ) arch_pattern="amd64" ;;
        arm64  ) arch_pattern="arm64\\|aarch64" ;;
        *      ) echo "Unsupported architecture: $architecture" >&2; exit 3 ;;
    esac

    local image_id
    image_id=$(openstack image list -f json | \
        jq -r --arg distro "$distro" --arg ver "$normalized_version" --arg arch "$arch_pattern" \
            '[.[] | select((.Name | ascii_downcase | contains($distro)) and (.Name | contains($ver)) and (.Name | ascii_downcase | test($arch)))]
             | first | .ID // empty' )

    if [ -z "$image_id" ]; then
        echo "ERROR: no image found for $distribution $version ($architecture)" >&2
        exit 1
    fi
    echo "$image_id"
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
        echo "Unable to parse memory size: $mem_size" >&2
        exit 3
    fi
    case "$units" in
        GB|GIB ) bc <<< "scale=0; ($value * 1024) / 1" ;;
        MB|MIB ) bc <<< "scale=0; $value / 1" ;;
        KB|KIB ) bc <<< "scale=0; ($value / 1024) / 1" ;;
        TB|TIB ) bc <<< "scale=0; ($value * 1024 * 1024) / 1" ;;
        B      ) bc <<< "scale=0; ($value / 1048576) / 1" ;;
        *      ) echo "Unsupported units: $units" >&2; exit 3 ;;
    esac
}

# ---------------------------------------------------------------------------
# find_flavor: select the smallest available flavor that satisfies the
# minimum CPU and memory requirements.
# Arguments: num_cpus mem_size_in_mb
# Prints the flavor name to stdout. Exits with code 1 on error.
# ---------------------------------------------------------------------------
find_flavor() {
    local cpus="$1"
    local ram_mb="$2"

    local flavor_name
    flavor_name=$(openstack flavor list -f json | \
        jq -r --argjson cpus "$cpus" --argjson ram "$ram_mb" '
            [.[] | select(.VCPUs >= $cpus and .RAM >= $ram)]
            | sort_by([.RAM, .VCPUs])
            | first
            | .Name')

    if [ -z "$flavor_name" ] || [ "$flavor_name" = "null" ]; then
        echo "ERROR: no flavor found with >= ${cpus} vCPUs and >= ${ram_mb} MB RAM" >&2
        exit 1
    fi
    echo "$flavor_name"
}

# Determine the image ID
if [ -n "${image_id}" ]; then
    OS_IMAGE_ID="$image_id"
else
    require_inputs os_architecture os_type os_distribution os_version

    if [ "${os_type,,}" != "linux" ]; then
        echo "Unsupported operating system type ${os_type}"
        exit 1
    fi

    OS_IMAGE_ID=$(find_image_id "${os_distribution,,}" "${os_version,,}" "${os_architecture,,}")
    if [ $? -ne 0 ]; then exit 1; fi
fi

echo "IMAGE ID: $OS_IMAGE_ID"

# Determine the flavor
if [ -n "${flavor}" ]; then
    SERVER_FLAVOR="$flavor"
else
    require_inputs host_num_cpus host_mem_size
    MEM_SIZE_IN_MB=$(mem_to_mb "$host_mem_size")
    SERVER_FLAVOR=$(find_flavor "$host_num_cpus" "$MEM_SIZE_IN_MB")
    if [ $? -ne 0 ]; then exit 1; fi
fi

echo "FLAVOR: $SERVER_FLAVOR"

# Add information about network ports if necessary
NW_ARGS=()
if [ -n "${ports}" ]; then
    # Make sure we have a list of port ids
    echo "$ports" | jq -e . > /dev/null 2>&1
    if [ $? -ne 0 ]; then
	# Convert to JSON list with one element
	ports="[\"$ports\"]"
    fi
    for port_id in $(jq -r '.[]' <<< "$ports");
    do
	NW_ARGS+=("--port" "$port_id")
    done
fi

echo "NETWORK ARGS: ${NW_ARGS[*]}"

# Create the server
OS_SERVER_ID=$(openstack server create \
    --image "$OS_IMAGE_ID" \
    --flavor "$SERVER_FLAVOR" \
    "${NW_ARGS[@]}" \
    --key-name "$key_name" \
    --format json \
    "$server_name" | jq -r ".id")

echo "New instance ID = ${OS_SERVER_ID}"

# Wait for server to become active
RETRY_COUNT=72    # Number of times to retry status check
RETRY_SLEEP=10    # How many seconds to sleep before trying again

until [[ "$(openstack server show "$OS_SERVER_ID" --format json | jq -r ".status")" == "ACTIVE" ]];
do
    if [[ "$RETRY_COUNT" -eq 0 ]]; then
	echo "Server failed to start"
	openstack server show "$OS_SERVER_ID"
	exit 1
    fi
    (( RETRY_COUNT-- ))
    sleep "$RETRY_SLEEP"
done

echo "SERVER ACTIVE"

# Return output values
SERVER_INFO=$(openstack server show "$OS_SERVER_ID" --format json)
echo "$SERVER_INFO"

server_id=$(jq -r '.id' <<< "$SERVER_INFO")

# Extract IPs: Rackspace uses plain strings in "public"/"private" networks;
# standard OpenStack uses objects with "OS-EXT-IPS:type" and "addr" fields.
ADDR_FORMAT=$(jq -r '.addresses | to_entries[0].value[0] | type' <<< "$SERVER_INFO")
if [ "$ADDR_FORMAT" = "object" ]; then
    private_ip=$(jq -r '[.addresses | to_entries[].value[] | select(."OS-EXT-IPS:type" == "fixed")    | .addr] | first // ""' <<< "$SERVER_INFO")
    public_ip=$(jq  -r '[.addresses | to_entries[].value[] | select(."OS-EXT-IPS:type" == "floating") | .addr] | first // ""' <<< "$SERVER_INFO")
else
    private_ip=$(jq -r '[(.addresses.private // []) | .[] | select(test("^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+$"))] | first // ""' <<< "$SERVER_INFO")
    public_ip=$(jq  -r '[(.addresses.public  // []) | .[] | select(test("^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+$"))] | first // ""' <<< "$SERVER_INFO")
fi

output "id: $server_id"
output "public_ip: $public_ip"
output "private_ip: $private_ip"
