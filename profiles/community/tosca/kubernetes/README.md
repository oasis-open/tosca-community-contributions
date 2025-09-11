# TOSCA Community Kubernetes Profile

This profile defines TOSCA types to support integration with
Kubernetes.

## Inventory

The following projects define node types related to containers and
kubernetes:

### Micado

> In the following diagram, the `tosca.nodes` prefix in the node type
  names is not shown to improve readability.

#### Configuration-Related Types
```mermaid
classDiagram
    Root <|-- MiCADO.Kubernetes
    Root <|-- MiCADO.Container.Config
    MiCADO.Container.Config <|-- MiCADO.Container.Config.Kubernetes
    MiCADO.Container.Config <|-- MiCADO.Container.Config.ConfigMap
```

#### Application Types
```mermaid
classDiagram
    Container.Application <|-- MiCADO.Container.Application
    MiCADO.Container.Application <|-- MiCADO.Container.Application.Pod
    MiCADO.Container.Application <|-- MiCADO.Container.Application.Docker
    MiCADO.Container.Application.Docker <|-- MiCADO.Container.Application.Docker.Init
    MiCADO.Container.Application.Docker <|-- MiCADO.Container.Application.Docker.Deployment
    MiCADO.Container.Application.Docker <|-- MiCADO.Container.Application.Docker.DaemonSet
    MiCADO.Container.Application.Docker <|-- MiCADO.Container.Application.Docker.Job
    MiCADO.Container.Application.Docker <|-- MiCADO.Container.Application.Docker.StatefulSet
    MiCADO.Container.Application.Pod <|-- MiCADO.Container.Pod.Kubernetes
    MiCADO.Container.Application.Pod <|-- MiCADO.Container.Application.Pod.Deployment
```

#### Storage Types
```mermaid
classDiagram
    BlockStorage <|-- MiCADO.Container.Volume
    MiCADO.Container.Volume <|-- MiCADO.Container.Volume.EmptyDir
    MiCADO.Container.Volume <|-- MiCADO.Container.Volume.HostPath
    MiCADO.Container.Volume <|-- MiCADO.Container.Volume.Local
    MiCADO.Container.Volume <|-- MiCADO.Container.Volume.NFS
    MiCADO.Container.Volume <|-- MiCADO.Container.Volume.GlusterFS
```

### Yorc

Yorc defines a collection of Kubernetes-related TOSCA types that are
based on Alien4Cloud type definitions.

```mermaid
classDiagram
    org.alien4cloud.kubernetes.api.types.DeploymentResource <|-- yorc.nodes.kubernetes.api.types.DeploymentResource
    org.alien4cloud.kubernetes.api.types.StatefulSetResource <|-- yorc.nodes.kubernetes.api.types.StatefulSetResource
    org.alien4cloud.kubernetes.api.types.JobResource <|-- yorc.nodes.kubernetes.api.types.JobResource
    org.alien4cloud.kubernetes.api.types.ServiceResource <|-- yorc.nodes.kubernetes.api.types.ServiceResource
    org.alien4cloud.kubernetes.api.types.SimpleResource <|-- yorc.nodes.kubernetes.api.types.SimpleResource
```
### Ubicity 
The following shows the Ubicity profile for Kubernetes:
```mermaid
classDiagram
    Root <|-- Resource
    Resource <|-- Namespace
    Resource <|-- NamespacedResource
    NamespacedResource <|-- ServiceAccount
    Resource <|-- ClusterRole
    Resource <|-- ClusterRoleBinding
    NamespacedResource <|-- ConfigMap
    Root <|-- HelmApp
```
### Puccini

Puccini takes a different approach than most other TOSCA projects: it
models entities using *capability types* rather than node types and
then composes node types as collections of capabilities. To reflect
this approach, the following diagrams show Puccini capability type
hieararchies rather than node type hiearchies. This type hierarchy
foces on type definitions in support of Kubernetes-based services.

```mermaid
classDiagram
    class Metadata
    class Resource
    Resource <|-- CustomResourceDefinition
    Resource <|-- Service
    Service <|-- ClusterIP
    ClusterIP <|-- NodePort
    NodePort <|-- LoadBalancer
    Service <|-- ExternalName
    Resource <|-- Controller
    Controller <|-- Deployment
    Resource <|-- NetworkAttachmentDefinition
    NetworkAttachmentDefinition <|-- BridgeNetworkAttachmentDefinition
```


