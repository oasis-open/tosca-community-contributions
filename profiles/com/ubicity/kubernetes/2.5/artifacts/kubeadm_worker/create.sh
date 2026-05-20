#!/bin/bash

#
# Install Kubernetes components and join a cluster using kubeadm.
#

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

require_inputs() {
    local missing=()
    for var_name in "$@"; do
        if [ -z "${!var_name:-}" ]; then
            missing+=("$var_name")
        fi
    done
    if [ ${#missing[@]} -gt 0 ]; then
        echo "Missing mandatory inputs: ${missing[*]}"
        exit 10
    fi
}

init_output

require_inputs join_token

# Determine Kubernetes minor version for the package repository.
if [ -n "${version:-}" ]; then
    K8S_MINOR="$version"
else
    K8S_MINOR=$(curl -fsSL https://dl.k8s.io/release/stable.txt | sed 's/^v//;s/\.[0-9]*$//')
    echo "No version specified, using latest stable: ${K8S_MINOR}"
fi

# ---------------------------------------------------------------------------
# Prerequisites: kernel modules and sysctl
# ---------------------------------------------------------------------------
echo "Configuring prerequisites..."

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system

# Disable swap
sudo swapoff -a
sudo sed -i '/\sswap\s/s/^/#/' /etc/fstab

# ---------------------------------------------------------------------------
# Install containerd
# ---------------------------------------------------------------------------
echo "Installing containerd..."
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y containerd

sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

# ---------------------------------------------------------------------------
# Install kubelet, kubeadm
# ---------------------------------------------------------------------------
echo "Installing Kubernetes ${K8S_MINOR} packages..."

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https ca-certificates curl gpg

KEYRING="/usr/share/keyrings/kubernetes-apt-keyring.gpg"
curl -fsSL "https://pkgs.k8s.io/core:/stable:/v${K8S_MINOR}/deb/Release.key" \
    | sudo gpg --yes --dearmor -o "$KEYRING"
echo "deb [signed-by=${KEYRING}] https://pkgs.k8s.io/core:/stable:/v${K8S_MINOR}/deb/ /" \
    | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y kubelet kubeadm
sudo apt-mark hold kubelet kubeadm

# ---------------------------------------------------------------------------
# Join the cluster
# ---------------------------------------------------------------------------
echo "Joining Kubernetes cluster..."

# Reset any previous kubeadm state to ensure a clean join
sudo kubeadm reset -f 2>/dev/null || true
sudo rm -rf /etc/cni/net.d
sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F
sudo systemctl restart containerd

# join_token contains the full join command from 'kubeadm token create --print-join-command'
sudo ${join_token}
if [ $? -ne 0 ]; then
    echo "ERROR: kubeadm join failed"
    exit 1
fi

echo "Worker node joined the cluster"
