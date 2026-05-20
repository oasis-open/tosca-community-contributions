#!/bin/bash

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
. "$HERE/../common_lib.sh"

init_output

require_inputs host

RETRY_COUNT=30   # Number of times to retry
RETRY_SLEEP=10   # How many seconds to sleep before trying again

echo -n "Wait for reboot "
sleep ${RETRY_SLEEP}
(( RETRY_COUNT-- ))
while ! nc -w 3 -z "${host}" 22 2> /dev/null
do
    if [[ "${RETRY_COUNT}" -eq 0 ]]; then
	echo "Reboot timed out"
	exit 1;
    fi
    echo -n .
    sleep ${RETRY_SLEEP}
    (( RETRY_COUNT-- ))
done
echo ""
echo "Reboot complete"
