#!/bin/bash

set -e

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

init_output

# Get the actual user (not root if using sudo)
ACTUAL_USER=${SUDO_USER:-$USER}

# Check CPU virtualization support
VT_SUPPORT=$(grep -E -c '(vmx|svm)' /proc/cpuinfo 2>/dev/null || true)

if [ "$VT_SUPPORT" -eq 0 ]; then
    echo "ERROR: CPU does not support virtualization (VT-x/AMD-V)"
    echo "Please enable virtualization in your BIOS/UEFI settings"
    echo "For VMware VMs, enable 'Virtualize Intel VT-x/EPT or AMD-V/RVI' in VM settings"
    exit 1
fi

echo "✓ CPU virtualization support detected ($VT_SUPPORT cores)"

# Detect CPU vendor
if grep -q "vmx" /proc/cpuinfo 2>/dev/null; then
    CPU_VENDOR="intel"
    KVM_MODULE="kvm_intel"
elif grep -q "svm" /proc/cpuinfo 2>/dev/null; then
    CPU_VENDOR="amd"
    KVM_MODULE="kvm_amd"
else
    echo "ERROR: Could not detect CPU vendor"
    exit 1
fi

echo "Detected CPU vendor: $CPU_VENDOR"

# Load KVM kernel modules
echo "Loading KVM kernel modules..."
sudo -n modprobe kvm
sudo -n modprobe $KVM_MODULE

# Verify KVM is loaded
if lsmod | grep -q "^kvm"; then
    echo "✓ KVM modules loaded successfully"
else
    echo "ERROR: Failed to load KVM modules"
    exit 1
fi

# Check if /dev/kvm exists
if [ -e /dev/kvm ]; then
    echo "✓ /dev/kvm device exists"
else
    echo "ERROR: /dev/kvm device not found"
    exit 1
fi

# Set permissions on /dev/kvm
echo "Setting permissions on /dev/kvm..."
sudo -n chmod 666 /dev/kvm

# Add current user to kvm and libvirt groups
echo "Adding user '$ACTUAL_USER' to kvm and libvirt groups..."
sudo -n usermod -aG kvm $ACTUAL_USER
sudo -n usermod -aG libvirt $ACTUAL_USER

# Enable and start libvirtd service
echo "Enabling and starting libvirtd service..."
sudo -n systemctl enable libvirtd
sudo -n systemctl start libvirtd

# Configure KVM modules to load at boot
echo "Configuring KVM modules to load at boot..."
sudo -n tee /etc/modules-load.d/kvm.conf <<EOF
kvm
${KVM_MODULE}
EOF

# Create udev rule for /dev/kvm permissions
echo "Creating udev rule for /dev/kvm permissions..."
sudo -n tee /etc/udev/rules.d/65-kvm.rules <<'EOF'
KERNEL=="kvm", GROUP="kvm", MODE="0666"
EOF

# Reload udev rules
sudo -n udevadm control --reload-rules
sudo -n udevadm trigger
