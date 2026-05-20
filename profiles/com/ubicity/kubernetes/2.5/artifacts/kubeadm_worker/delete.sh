#!/bin/bash

#
# Remove the worker from the cluster and uninstall Kubernetes packages.
#

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

init_output

echo "Removing worker node..."

# Reset kubeadm
sudo kubeadm reset -f

# Remove Kubernetes packages
sudo apt-mark unhold kubelet kubeadm 2>/dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get purge -y kubelet kubeadm
sudo apt-get autoremove -y

# Clean up
sudo rm -rf /etc/kubernetes /var/lib/kubelet /etc/cni/net.d
sudo rm -f /etc/apt/sources.list.d/kubernetes.list
sudo rm -f /usr/share/keyrings/kubernetes-apt-keyring.gpg

# Remove containerd
sudo DEBIAN_FRONTEND=noninteractive apt-get purge -y containerd
sudo rm -rf /etc/containerd

echo "Worker node removed"
