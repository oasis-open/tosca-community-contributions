#!/bin/sh
set -e

if [ -f /tmp/configured ]; then
	exit 0
fi

NODE_TEMPLATE=$1

if ! grep -qF TOSCA /usr/src/app/views/home.handlebars; then
	echo "<div style=\"font-size:32pt\">Part of TOSCA node: \"$NODE_TEMPLATE\"</div>" >> /usr/src/app/views/home.handlebars
fi

touch /tmp/configured
