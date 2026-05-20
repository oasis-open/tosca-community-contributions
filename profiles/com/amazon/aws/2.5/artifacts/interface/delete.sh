#!/bin/bash

# This script expects the following environment variables:
#
#          aws_credentials_file
#          aws_region_name
#          aws_interface_id
#
# Optional environment variables:
#
#          aws_profile

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs aws_region_name aws_interface_id

get_attachment_status() {
    aws ec2 describe-network-interfaces \
	--region                "$aws_region_name" \
	--network-interface-ids "$aws_interface_id" \
	--output text \
	--query 'NetworkInterfaces[0].Attachment.Status'
}

# Timeout configuration.
RETRY_COUNT=12
RETRY_SLEEP=5

# Make sure interface is no longer attached before trying to delete.
# Treat null (never attached) or None (detached) as ready to delete.
STATUS=$(get_attachment_status)
until [[ "$STATUS" == "None" || "$STATUS" == "null" || -z "$STATUS" ]]; do
    if [[ "$RETRY_COUNT" -eq 0 ]]; then
	exit 1
    fi
    (( RETRY_COUNT-- ))
    sleep "$RETRY_SLEEP"
    STATUS=$(get_attachment_status)
done

# Delete the network interface.
aws ec2 delete-network-interface \
    --region               "$aws_region_name" \
    --network-interface-id "$aws_interface_id"
