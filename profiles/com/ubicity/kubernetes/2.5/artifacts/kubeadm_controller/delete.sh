#!/bin/bash

#
# Tear down the kubeadm cluster and remove Kubernetes packages.
#

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

init_output

echo "Tearing down kubeadm cluster..."

# Reset kubeadm
sudo kubeadm reset -f

# Remove Kubernetes packages
sudo apt-mark unhold kubelet kubeadm kubectl 2>/dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get purge -y kubelet kubeadm kubectl
sudo apt-get autoremove -y

# Clean up configuration and data
sudo rm -rf /etc/kubernetes /var/lib/kubelet /var/lib/etcd /etc/cni/net.d
sudo rm -f /etc/apt/sources.list.d/kubernetes.list
sudo rm -f /usr/share/keyrings/kubernetes-apt-keyring.gpg

# Remove containerd
sudo DEBIAN_FRONTEND=noninteractive apt-get purge -y containerd
sudo rm -rf /etc/containerd

echo "Kubeadm cluster removed"
