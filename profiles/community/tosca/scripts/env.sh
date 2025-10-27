_HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")

WORKSPACE_DIR=$(readlink --canonicalize "$_HERE/..")
CSARS_DIR=/tmp/csars
PROFILES_DIR="${WORKSPACE_DIR}"
SUBSTITUTIONS_DIR="${WORKSPACE_DIR}/substitutions"
RESOURCES_DIR="${WORKSPACE_DIR}/resources"
EXAMPLES_DIR="${WORKSPACE_DIR}/examples"
