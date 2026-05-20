#!/bin/bash

#
# Install Kubernetes components and initialize a cluster using kubeadm.
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

require_inputs name

POD_CIDR="${pod_cidr:-10.244.0.0/16}"

# Determine Kubernetes minor version for the package repository.
# The version property specifies a minor version (e.g. "1.30").
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

# Disable swap (required by kubelet)
sudo swapoff -a
sudo sed -i '/\sswap\s/s/^/#/' /etc/fstab

# ---------------------------------------------------------------------------
# Install containerd
# ---------------------------------------------------------------------------
echo "Installing containerd..."
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y containerd

# Configure containerd with systemd cgroup driver
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

# ---------------------------------------------------------------------------
# Install kubelet, kubeadm, kubectl
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
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo "Kubernetes packages installed"

# ---------------------------------------------------------------------------
# Initialize the cluster
# ---------------------------------------------------------------------------
echo "Initializing Kubernetes cluster: $name"

# Reset any previous kubeadm state to ensure a clean initialization
sudo kubeadm reset -f 2>/dev/null || true
sudo rm -rf /etc/cni/net.d
sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F
sudo systemctl restart containerd

# Use the exact installed kubeadm version to avoid remote version lookup
KUBEADM_VERSION=$(kubeadm version -o short)

INIT_ARGS=(
    --pod-network-cidr="$POD_CIDR"
    --kubernetes-version="$KUBEADM_VERSION"
)
[ -n "${api_server_address:-}" ] && INIT_ARGS+=(--apiserver-advertise-address="$api_server_address")
[ -n "${api_server_public_address:-}" ] && INIT_ARGS+=(--apiserver-cert-extra-sans="$api_server_public_address")

sudo kubeadm init "${INIT_ARGS[@]}"
if [ $? -ne 0 ]; then
    echo "ERROR: kubeadm init failed"
    exit 1
fi

# Set up kubeconfig for kubectl on the controller node
mkdir -p "$HOME/.kube"
sudo cp /etc/kubernetes/admin.conf "$HOME/.kube/config"
sudo chown "$(id -u):$(id -g)" "$HOME/.kube/config"

# Remove the control-plane taint so workloads can run on a single-node
# cluster. If worker nodes are added later, the scheduler will spread
# pods across all nodes automatically.
kubectl taint nodes --all node-role.kubernetes.io/control-plane- 2>/dev/null || true

# Install Flannel CNI plugin for pod networking
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

echo "Kubernetes cluster initialized"
