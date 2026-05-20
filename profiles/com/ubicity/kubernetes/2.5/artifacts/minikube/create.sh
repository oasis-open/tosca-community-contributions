#!/bin/bash

#
# Install Minikube on Linux
#

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

init_output

# Install prerequisites for --driver=none
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y conntrack socat

# Install crictl
CRICTL_VERSION=$(curl -sSL https://api.github.com/repos/kubernetes-sigs/cri-tools/releases/latest | jq -r .tag_name)
curl -sSL "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz" | sudo tar -C /usr/local/bin -xz

# Download Minikube package
cd /tmp
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb

# Install
sudo dpkg -i minikube_latest_amd64.deb
rm -f minikube_latest_amd64.deb
