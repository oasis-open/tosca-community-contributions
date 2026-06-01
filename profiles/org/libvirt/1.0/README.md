# org.libvirt:1.0

TOSCA profile for [libvirt](https://libvirt.org) and the underlying
KVM hypervisor — the foundation for most Linux virtualization
platforms.

## Types

- **Kvm** — installation of KVM and libvirt on a Linux host, exposing
  a `HyperVisor` capability.

## Expected consumers

Virtualization platforms that run on top of KVM/libvirt — KubeVirt,
oVirt, OpenNebula, Apache CloudStack, Nutanix AHV, etc. — import this
profile rather than redefining the hypervisor primitives.

## Roadmap

- A `Libvirt` node type for the libvirt management layer itself
  (separate from the underlying `Kvm` install).
- Lifecycle artifacts that drive `virsh` / libvirt APIs directly,
  letting downstream profiles manage VMs without going through a
  higher-level platform.
- Downstream virtualization-platform profiles (oVirt, OpenNebula,
  CloudStack, Nutanix AHV) that import `org.libvirt:1.0` rather than
  redefining KVM primitives.
