#!/bin/bash
#
# This script installs a Helm chart
#
# Mandatory environment variables:
#      deployment_name: The name for this deployment
#      chart: The name of the chart from which to create the
#             installation
#      values: The map of values from which to create the
#             installation
#      values_file: Name of a file that contains values
#      kubeconfig: The name of the kubectl config file

#      cluster_name: The name of the kubernetes cluster on which to
#      deploy this Helm app

# Optional environment variables:
#
#      NOTE: one of the following two has to be provided:
#
#      repo_name: name of the repository from which to retrieve the
#      chart
#
#      repo_url: url of the repository from which to retrieve the
#      chart
#
#      namespace_name: The name of the namespace within which to
#                      create this config map
#

# LOG_FILE is set by the Executor

# Make sure mandatory environment variables are set
if [ -z "${deployment_name}" ]; then
    echo "deployment_name is not set" >> "${LOG_FILE}"
    exit 10
fi
if [ -z "${chart}" ]; then
    echo "chart is not set" >> "${LOG_FILE}"
    exit 10
fi
if [ ! -z "${repo_name}" ] && [ ! -z "${repo_url}" ]; then
    echo "Both repo_name and repo_url are set" >> "${LOG_FILE}"
    exit 10
fi
if [ -z "${kubeconfig}" ]; then
    echo "kubeconfig is not set" >> "${LOG_FILE}"
    exit 10
fi
if [ -z "${cluster_name}" ]; then
    echo "cluster_name is not set" >> "${LOG_FILE}"
    exit 10
fi

# Environment variables containing file names may include tilde
# characters, which will not get expanded (since bash does tilde
# expansion before variable expansion). Manually replace ~ if
# necessary. Note that replacement is bash-specific and not portable
# to other shells.

KUBECONFIG="${kubeconfig//\~/$HOME}"

# Create cluster context
KUBECONTEXT=kubernetes-admin@${cluster_name}

# Process repo and chart environment variables
if [ ! -z "${repo_name}" ]; then
    # Qualify chart name with repo name
    CHART_REF="${repo_name}"/"${chart}"
    REPO_ARG=""
elif [ ! -z "${repo_url}" ]; then
    # Specify repository url using command line option
    CHART_REF="${chart}"
    REPO_ARG="--repo ${repo_url}"
else
    # No repo. Chart must refer to a local file
    CHART_REF="${chart}"
    REPO_ARG=""
fi

OPTIONAL_ARGS=""
# Specify namespace if necessary
if [ ! -z "${namespace_name}" ]; then
    OPTIONAL_ARGS="${OPTIONAL_ARGS} --namespace ${namespace_name}"
fi

# Handle values
if [ ! -z "${values}" ]; then
    echo values = ${values} >> ${LOG_FILE}
    for KEY in $(jq -r 'keys[]' <<<$values);
    do
	VALUE=$(jq -r " .[\"${KEY}\"] " <<<$values);
	OPTIONAL_ARGS="${OPTIONAL_ARGS} --set ${KEY}=${VALUE}"
    done
fi

if [ ! -z "${values_file}" ]; then
    OPTIONAL_ARGS="${OPTIONAL_ARGS} -f ${values_file}"
fi
echo $OPTIONAL_ARGS >> ${LOG_FILE}

# Create the installation
helm install "${deployment_name}" "${CHART_REF}" ${REPO_ARG} ${OPTIONAL_ARGS} \
     --kubeconfig $KUBECONFIG --kube-context ${KUBECONTEXT}  >> "${LOG_FILE}" 2>&1

