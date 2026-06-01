#!/bin/bash

# This script expects the following environment variables:
#
#          aws_credentials_file
#          aws_region_name
#          aws_key_name
#
# Optional Environment Variables:
#
#          image_id             (if provided, used directly as the AMI ID)
#          os_architecture     (mandatory if image_id is not provided)
#          os_type             (mandatory if image_id is not provided)
#          os_distribution     (mandatory if image_id is not provided)
#          os_version          (mandatory if image_id is not provided)
#          instance_type        (if provided, used directly for --instance-type)
#          host_num_cpus        (mandatory if instance_type is not provided)
#          host_mem_size        (mandatory if instance_type is not provided)
#          server_name
#          hostname
#          host_cpu_frequency
#          host_disk_size
#          aws_network_interfaces
#          aws_security_group_id
#          aws_profile

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs aws_region_name aws_key_name

# ---------------------------------------------------------------------------
# mem_to_mib: convert a TOSCA scalar memory value (e.g. "1.5 GB") to MiB.
# Prints the result to stdout. Exits with code 3 on error.
# ---------------------------------------------------------------------------
mem_to_mib() {
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
# select_instance_type: select a T3 instance type based on CPUs and memory.
# Arguments: host_num_cpus mem_size_in_mib
# Prints the instance type to stdout. Exits with code 3 on error.
#
# T3 types have the following characteristics:
#
# Name        vCPUs    RAM (GiB)
# t3.nano     2        0.5
# t3.micro    2        1.0
# t3.small    2        2.0
# t3.medium   2        4.0
# t3.large    2        8.0
# t3.xlarge   4        16.0
# t3.2xlarge  8        32.0
#
# Note: all T3 instances have a minimum of 2 vCPUs, so CPU count only
# matters at the 4 and 8 vCPU boundaries.
# ---------------------------------------------------------------------------
select_instance_type() {
    local cpus="$1"
    local mib="$2"
    local arch="${3:-x86_64}"

    # Use T4g (Graviton/ARM64) or T3 (x86_64)
    local family="t3"
    [ "$arch" = "arm64" ] && family="t4g"

    if [ "$cpus" -gt 8 ]; then
        echo "Unsupported number of CPUs ($cpus)" >&2; exit 3
    fi

    if (( mib > 32768 )); then
        echo "Unsupported memory size (${mib} MiB)" >&2; exit 3
    elif (( mib > 16384 )); then
        echo "${family}.2xlarge"
    elif (( mib > 8192 )); then
        [ "$cpus" -gt 4 ] && echo "${family}.2xlarge" || echo "${family}.xlarge"
    elif (( mib > 4096 )); then
        if   [ "$cpus" -gt 4 ]; then echo "${family}.2xlarge"
        elif [ "$cpus" -gt 2 ]; then echo "${family}.xlarge"
        else                          echo "${family}.large"
        fi
    elif (( mib > 2048 )); then
        if   [ "$cpus" -gt 4 ]; then echo "${family}.2xlarge"
        elif [ "$cpus" -gt 2 ]; then echo "${family}.xlarge"
        else                          echo "${family}.medium"
        fi
    elif (( mib > 1024 )); then
        if   [ "$cpus" -gt 4 ]; then echo "${family}.2xlarge"
        elif [ "$cpus" -gt 2 ]; then echo "${family}.xlarge"
        else                          echo "${family}.small"
        fi
    elif (( mib > 512 )); then
        if   [ "$cpus" -gt 4 ]; then echo "${family}.2xlarge"
        elif [ "$cpus" -gt 2 ]; then echo "${family}.xlarge"
        else                          echo "${family}.micro"
        fi
    else
        if   [ "$cpus" -gt 4 ]; then echo "${family}.2xlarge"
        elif [ "$cpus" -gt 2 ]; then echo "${family}.xlarge"
        else                          echo "${family}.nano"
        fi
    fi
}

# ---------------------------------------------------------------------------
# find_ami_id: find the current AMI ID for the given distribution,
# version, and architecture using AWS Systems Manager Parameter Store,
# which is maintained by AWS and distribution vendors and always points
# to the latest current image.
# Arguments: distribution version architecture
# Prints the AMI ID to stdout. Exits with code 1, 2, or 3 on error.
#
# Supported distributions and versions:
#   ubuntu: 24.04, 22.04  (SSM maintained by Canonical)
#   debian: 12, 11         (SSM maintained by Debian)
#   rhel:   9, 8           (describe-images; no standard SSM path)
#
# Supported architectures: x86_64, arm64
# ---------------------------------------------------------------------------
find_ami_id() {
    local distribution="$1"
    local version="$2"
    local architecture="$3"

    # Canonical and Debian SSM paths use "amd64" instead of "x86_64"
    local ssm_arch
    case "$architecture" in
        x86_64 ) ssm_arch="amd64" ;;
        arm64  ) ssm_arch="arm64" ;;
        * ) echo "Unsupported architecture: $architecture" >&2; exit 3 ;;
    esac

    local ami_id ssm_path

    case "$distribution" in
        "ubuntu" )
            case "$version" in
                "24.04"|"22.04" )
                    ssm_path="/aws/service/canonical/ubuntu/server/${version}/stable/current/${ssm_arch}/hvm/ebs-gp2/ami-id"
                    ;;
                * ) echo "Unsupported Ubuntu version $version" >&2; exit 3 ;;
            esac
            ami_id=$(aws ssm get-parameter \
                         --region "$aws_region_name" \
                         --name   "$ssm_path" \
                         --query  'Parameter.Value' \
                         --output text)
            ;;
        "debian" )
            case "$version" in
                "12"|"11" )
                    ssm_path="/aws/service/debian/release/${version}/latest/${ssm_arch}/hvm/ebs-gp2/ami-id"
                    ;;
                * ) echo "Unsupported Debian version $version" >&2; exit 3 ;;
            esac
            ami_id=$(aws ssm get-parameter \
                         --region "$aws_region_name" \
                         --name   "$ssm_path" \
                         --query  'Parameter.Value' \
                         --output text)
            ;;
        "rhel" )
            # RHEL has no standard SSM path; use describe-images instead
            local owner=309956199498 # Red Hat Cloud account
            local filter
            case "$version" in
                9* ) filter="RHEL-9*_HVM-*-GP3" ;;
                8* ) filter="RHEL-8*_HVM-*-GP3" ;;
                * ) echo "Unsupported RHEL version $version" >&2; exit 3 ;;
            esac
            ami_id=$(aws ec2 describe-images \
                         --owners  "$owner" \
                         --region  "$aws_region_name" \
                         --filters Name=virtualization-type,Values=hvm \
                                   Name=architecture,Values="$architecture" \
                                   Name=name,Values="$filter" \
                         --output  text \
                         --query   'sort_by(Images,&CreationDate)[-1].ImageId')
            ;;
        * )
            echo "Unsupported Linux distribution: $distribution" >&2; exit 2
            ;;
    esac

    if [ -z "$ami_id" ] || [ "$ami_id" = "None" ]; then
        echo "ERROR: no AMI found for $distribution $version ($architecture)" >&2
        exit 1
    fi
    echo "$ami_id"
}

# ---------------------------------------------------------------------------
# wait_for_running: wait until the instance reaches the "running" state.
# Timeout: 5 minutes.
# ---------------------------------------------------------------------------
wait_for_running() {
    local retry_count=30
    local retry_sleep=10

    until [[ "$(get_instance_status)" == "running" ]]; do
        if [[ "$retry_count" -eq 0 ]]; then
            echo "ERROR: timed out waiting for instance $AWS_INSTANCE_ID to start" >&2
            exit 1
        fi
        (( retry_count-- ))
        sleep "$retry_sleep"
    done
}

get_instance_status() {
    aws ec2 describe-instances \
        --region      "$aws_region_name" \
        --instance-id "$AWS_INSTANCE_ID" \
        --output text \
        --query 'Reservations[0].Instances[0].State.Name'
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

# Determine the AMI ID
if [ -n "${image_id}" ]; then
    AWS_IMAGE_ID="$image_id"
else
    require_inputs os_architecture os_type os_distribution os_version

    # Make sure Operating System type is supported. We only support Linux for now.
    if [ "${os_type,,}" != "linux" ]; then
        echo "Unsupported operating system type $os_type"
        exit 1
    fi

    AWS_IMAGE_ID=$(find_ami_id "${os_distribution,,}" "${os_version,,}" "${os_architecture,,}")
    if [ $? -ne 0 ]; then exit 1; fi
fi

# Determine the instance type
if [ -n "${instance_type}" ]; then
    aws_instance_type="$instance_type"
else
    require_inputs host_num_cpus host_mem_size
    MEM_SIZE_IN_MIB=$(mem_to_mib "$host_mem_size")
    aws_instance_type=$(select_instance_type "$host_num_cpus" "$MEM_SIZE_IN_MIB" "${os_architecture:-x86_64}")
fi

# Build network arguments
NW_ARGS=()
if [ -n "${aws_network_interfaces}" ]; then
    aws_network_interfaces=$(jq -Rc '. as $raw | try ($raw | fromjson) catch [$raw]' <<< "$aws_network_interfaces")
    NW_JSON=$(jq -c '[to_entries[] | {"DeviceIndex": .key, "NetworkInterfaceId": .value}]' <<< "$aws_network_interfaces")
    NW_ARGS=(--network-interfaces "$NW_JSON")
elif [ -n "${aws_security_group_id}" ]; then
    NW_ARGS=(--security-group-ids "$aws_security_group_id")
fi

# Build optional arguments
USER_DATA_ARGS=()
if [ -n "${hostname}" ]; then
    USER_DATA_ARGS=(--user-data "#!/bin/bash
hostnamectl set-hostname ${hostname}")
fi

TAG_ARGS=()
if [ -n "${server_name}" ]; then
    TAG_ARGS=(--tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=\"${server_name}\"}]")
fi

# Launch the instance
RESULT=$(aws ec2 run-instances \
             --region        "$aws_region_name" \
             --count         1 \
             --image-id      "$AWS_IMAGE_ID" \
             --instance-type "$aws_instance_type" \
             --key-name      "$aws_key_name" \
             "${NW_ARGS[@]}" \
             "${TAG_ARGS[@]}" \
             "${USER_DATA_ARGS[@]}" \
             --output json)
if [ $? -ne 0 ] || [ -z "$RESULT" ]; then
    echo "ERROR: failed to launch instance"
    exit 1
fi

AWS_INSTANCE_ID=$(jq -r '.Instances[0].InstanceId' <<< "$RESULT")
echo "New instance ID = $AWS_INSTANCE_ID"

# Wait until the instance is running
wait_for_running

# Return instance details
INSTANCE_INFO=$(aws ec2 describe-instances \
                    --region      "$aws_region_name" \
                    --instance-id "$AWS_INSTANCE_ID" \
                    --output json \
                    --query 'Reservations[0].Instances[0]')
if [ $? -ne 0 ] || [ -z "$INSTANCE_INFO" ]; then
    echo "ERROR: failed to describe instance"
    exit 1
fi

instance_id=$(jq -r '.InstanceId' <<< "$INSTANCE_INFO")
public_ip=$(jq -r '.PublicIpAddress // ""' <<< "$INSTANCE_INFO")
private_ip=$(jq -r '.PrivateIpAddress // ""' <<< "$INSTANCE_INFO")
attachment_ids=$(jq -c '[.NetworkInterfaces[].Attachment.AttachmentId]' <<< "$INSTANCE_INFO")
device_indices=$(jq -c '[.NetworkInterfaces[].Attachment.DeviceIndex]' <<< "$INSTANCE_INFO")

output "instance_id: $instance_id"
output "public_ip: $public_ip"
output "private_ip: $private_ip"
output "attachment_id: $attachment_ids"
output "device_index: $device_indices"
