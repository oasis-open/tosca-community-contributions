_HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")

WORKSPACE_DIR=$(readlink --canonicalize "$_HERE/../..")
CSARS_DIR=/tmp/csars
PROFILES_DIR="${WORKSPACE_DIR}/profiles"
EXAMPLES_DIR="${WORKSPACE_DIR}/examples"
SUBSTITUTIONS_DIR="${EXAMPLES_DIR}/substitutions"
