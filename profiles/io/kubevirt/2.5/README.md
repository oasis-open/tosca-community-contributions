# io.kubevirt:2.5

TOSCA profile for [KubeVirt](https://kubevirt.io), a virtualization
platform that runs on top of Kubernetes.

## Type hierarchy

```mermaid
classDiagram
    ubct_IaasPlatform <|-- Kubevirt
    ubct_Software <|-- Virtctl
    ubct_VirtualCompute <|-- Compute
    Compute --> Kubevirt:VirtualizedUsing
    Virtctl --> Kubevirt:Manages
```

## Node types

- **Kubevirt** — an installation of KubeVirt on a Kubernetes cluster.
  Derived from `ubct:IaasPlatform`; plays the same role as `Aws`,
  `Azure`, `Proxmox`, etc. in its respective profile.
- **Virtctl** — installation of the `virtctl` CLI tool.
- **Compute** — a virtual machine hosted on KubeVirt, modeled as a
  Kubernetes custom resource.
