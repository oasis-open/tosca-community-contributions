#!/bin/bash

set -e

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

init_output

# Get actual user
ACTUAL_USER=${SUDO_USER:-$USER}

# Stop libvirtd service
echo "Stopping libvirtd service..."
sudo systemctl stop libvirtd || true
sudo systemctl disable libvirtd || true

# Unload KVM kernel modules
echo "Unloading KVM kernel modules..."
sudo rmmod kvm_intel || true
sudo rmmod kvm_amd || true
sudo rmmod kvm || true

# Remove user from kvm and libvirt groups
echo "Removing user '$ACTUAL_USER' from kvm and libvirt groups..."
sudo gpasswd -d $ACTUAL_USER kvm || true
sudo gpasswd -d $ACTUAL_USER libvirt || true

# Remove configuration files
echo "Removing configuration files..."
sudo rm -f /etc/modules-load.d/kvm.conf
sudo rm -f /etc/udev/rules.d/65-kvm.rules

# Reload udev rules
sudo udevadm control --reload-rules || true
sudo udevadm trigger || true
