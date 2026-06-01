#!/bin/bash

# This script expects the following environment variables:
#
#          aws_credentials_file
#          aws_region_name
#          aws_vpc_id
#
# Optional environment variables:
#
#          aws_routes
#          aws_profile

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs aws_region_name aws_vpc_id

# Create a Route Table on a Virtual Private Cloud
RESULT=$(aws ec2 create-route-table \
	      --region  "$aws_region_name" \
	      --vpc-id  "$aws_vpc_id" \
	      --output json)
if [ $? -ne 0 ] || [ -z "$RESULT" ]; then
    echo "ERROR: failed to create route table"
    exit 1
fi

ROUTE_TABLE_ID=$(jq -r '.RouteTable.RouteTableId' <<< "$RESULT")

# Then, add each route
if [ -n "${aws_routes}" ]; then
    while IFS= read -r route; do
	echo "Installing route $route"
	DEST=$(jq -r '.destination_cidr' <<< "$route")
	GW=$(jq -r '.target_gateway_id' <<< "$route")
	echo "Route arguments: --destination-cidr-block $DEST --gateway-id $GW"
	aws ec2 create-route \
	    --region          "$aws_region_name" \
	    --route-table-id  "$ROUTE_TABLE_ID" \
	    --destination-cidr-block "$DEST" \
	    --gateway-id      "$GW"
    done < <(jq -c '.[]' <<< "$aws_routes")
fi

output "aws_route_table_id: $ROUTE_TABLE_ID"
