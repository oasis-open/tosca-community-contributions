#!/bin/bash

# This script expects the following mandatory inputs:
#
#          aws_credentials_file
#          aws_region_name
#          aws_group_name
#          aws_group_description
#
# Optional inputs:
#
#          aws_vpc_id
#          aws_ingress_rules
#          aws_egress_rules
#          aws_profile

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs aws_region_name aws_group_name aws_group_description

REGION_ARGS=(--region "$aws_region_name")

# aws_vpc_id is not mandatory. Add VPC argument if present.
VPC_ARGS=()
[ -n "${aws_vpc_id}" ] && VPC_ARGS=(--vpc-id "$aws_vpc_id")

# Create unique name
SALT=$(md5sum <<< "$RANDOM" | head -c 6)
security_group_name='ubct-sg'"${SALT}"

# First, create the security group
RESULT=$(aws ec2 create-security-group \
	       --group-name        "$security_group_name" \
	       --tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=\"${aws_group_name}\"}]" \
	       --description       "$aws_group_description" \
	       "${REGION_ARGS[@]}" "${VPC_ARGS[@]}" \
	       --output json)
if [ $? -ne 0 ] || [ -z "$RESULT" ]; then
    echo "ERROR: failed to create security group"
    exit 1
fi

GROUP_ID=$(jq -r '.GroupId' <<< "$RESULT")

# Always add an ingress rule allowing all traffic from the same
# security group. Note that we will introduce a separate node type for
# security group rules.
aws ec2 authorize-security-group-ingress \
    "${REGION_ARGS[@]}" --group-id "$GROUP_ID" --protocol tcp --port '0-65535' --source-group "$GROUP_ID"

# Then, add each ingress rule
if [ -n "${aws_ingress_rules}" ]; then
    echo "aws_ingress_rules: ${aws_ingress_rules}"
    while IFS= read -r rule; do
	PROTO=$(jq -r '.protocol' <<< "$rule")
	PORT=$(jq -r '.port' <<< "$rule")
	CIDR=$(jq -r '.cidr' <<< "$rule")
	echo "aws ec2 authorize-security-group-ingress ${REGION_ARGS[*]} --group-id $GROUP_ID --protocol $PROTO --port $PORT --cidr $CIDR"
	aws ec2 authorize-security-group-ingress \
	    "${REGION_ARGS[@]}" --group-id "$GROUP_ID" \
	    --protocol "$PROTO" --port "$PORT" --cidr "$CIDR"
    done < <(jq -c '.[]' <<< "$aws_ingress_rules")
fi

# Finally, add each egress rule
if [ -n "${aws_egress_rules}" ]; then
    echo "aws_egress_rules: ${aws_egress_rules}"
    while IFS= read -r rule; do
	PROTO=$(jq -r '.protocol' <<< "$rule")
	PORT=$(jq -r '.port' <<< "$rule")
	CIDR=$(jq -r '.cidr' <<< "$rule")
	echo "aws ec2 authorize-security-group-egress ${REGION_ARGS[*]} --group-id $GROUP_ID --protocol $PROTO --port $PORT --cidr $CIDR"
	aws ec2 authorize-security-group-egress \
	    "${REGION_ARGS[@]}" --group-id "$GROUP_ID" \
	    --protocol "$PROTO" --port "$PORT" --cidr "$CIDR"
    done < <(jq -c '.[]' <<< "$aws_egress_rules")
fi

# Return group ID
output "group_id: $GROUP_ID"
