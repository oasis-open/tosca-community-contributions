#!/bin/bash
#
# This script configures Container Runtime Interface on Containerd
#
# Based on https://kubernetes.io/docs/setup/production-environment/container-runtimes/
#
# Copied from
# https://www.itzgeek.com/how-tos/linux/ubuntu-how-tos/install-containerd-on-ubuntu-22-04.html
#
#    LOG_FILE (Set by the Executor)

# Add the necessary configuations to the config.toml file
cat <<EOF | sudo tee -a /etc/containerd/config.toml >> ${LOG_FILE} 2>&1
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
SystemdCgroup = true
EOF

# Enable the plugin
sudo sed -i 's/^disabled_plugins \=/\#disabled_plugins \=/g' /etc/containerd/config.toml >> ${LOG_FILE} 2>&1

# Network configuration
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf >> ${LOG_FILE} 2>&1
overlay
br_netfilter
EOF

sudo modprobe overlay >> ${LOG_FILE} 2>&1
sudo modprobe br_netfilter >> ${LOG_FILE} 2>&1

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf >> ${LOG_FILE} 2>&1
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system >> ${LOG_FILE} 2>&1
