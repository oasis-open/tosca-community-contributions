#!/bin/bash

# This script expects the following environment variables:
#
#          aws_credentials_file
#          aws_region_name
#          aws_attachment_id
#
# Optional environment variables:
#
#          aws_profile

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs aws_region_name aws_attachment_id

# It is OK for this command to fail, since the interface might have
# already been detached when the instance is terminated.  Detach the
# network interface.
aws ec2 detach-network-interface \
    --region        "$aws_region_name" \
    --attachment-id "$aws_attachment_id" || true
