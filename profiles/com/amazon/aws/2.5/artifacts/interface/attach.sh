#!/bin/bash

# This script expects the following environment variables:
#
#          aws_credentials_file
#          aws_region_name
#          aws_interface_id
#          aws_instance_id
#          aws_device_index
#
# Optional environment variables:
#
#          aws_profile

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs aws_region_name aws_interface_id aws_instance_id aws_device_index

RESULT=$(aws ec2 attach-network-interface \
	     --region               "$aws_region_name" \
	     --network-interface-id "$aws_interface_id" \
	     --instance-id          "$aws_instance_id" \
	     --device-index         "$aws_device_index" \
	     --output json)
if [ $? -ne 0 ] || [ -z "$RESULT" ]; then
    echo "ERROR: failed to attach network interface"
    exit 1
fi

attachment_id=$(jq -r '.AttachmentId' <<< "$RESULT")
output "attachment_id: $attachment_id"

# Make sure interface is attached before returning
get_attachment_status() {
    aws ec2 describe-network-interfaces \
	--region                "$aws_region_name" \
	--network-interface-ids "$aws_interface_id" \
	--output text \
	--query 'NetworkInterfaces[0].Attachment.Status'
}

RETRY_COUNT=12
RETRY_SLEEP=5
until [[ "$(get_attachment_status)" == "attached" ]]; do
    if [[ "$RETRY_COUNT" -eq 0 ]]; then
	exit 1
    fi
    (( RETRY_COUNT-- ))
    sleep "$RETRY_SLEEP"
done
