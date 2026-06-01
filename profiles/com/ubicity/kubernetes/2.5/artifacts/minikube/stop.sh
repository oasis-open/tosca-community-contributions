#!/bin/bash

#
# Stop Minikube Cluster
#

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

require_inputs() {
    local missing=()
    for var_name in "$@"; do
        local var_value="${!var_name:-}"
        if [ -z "$var_value" ]; then
            missing+=("$var_name")
        fi
    done
    if [ ${#missing[@]} -gt 0 ]; then
        echo "Missing mandatory inputs: ${missing[*]}"
        exit 10
    fi
}

init_output

sudo systemctl disable kubelet || true
sudo systemctl stop kubelet || true
sudo pkill -f kube-apiserver || true
sudo pkill -f kube-controller-manager || true
sudo pkill -f kube-scheduler || true
sudo pkill -f etcd || true
