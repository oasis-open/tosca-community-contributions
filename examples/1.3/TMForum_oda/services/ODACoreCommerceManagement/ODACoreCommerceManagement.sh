#!/bin/bash
#options '-validate' - service will be validated but not loaded

# Exit on first error
set -e
THIS_SERVICE="ODACoreCommerceManagement"
TOSCA_DIR=~/Workspace/tosca
WORKSPACE=$(readlink --canonicalize "$TOSCA_DIR/..")

CSAR_DIR="${TOSCA_DIR}"/csars
UBICITY_DIR="${WORKSPACE}"/ubicity

SERVICES_DIR="${TOSCA_DIR}"/services


# Create new archive for $THIS_SERVICE
cd ~/Workspace/tosca/services/${THIS_SERVICE}
rm -f ${CSAR_DIR}/${THIS_SERVICE}.csar
zip -r ${CSAR_DIR}/${THIS_SERVICE}.csar .

# Initialize
# cd "${UBICITY_DIR}"
# . env/bin/activate

# Run scenario for $THIS_SERVICE
if [ "$1" = validate ]; then
    ubicity catalog validate ${CSAR_DIR}/${THIS_SERVICE}.csar
else
    ubicity catalog add ${CSAR_DIR}/${THIS_SERVICE}.csar
fi
