# TOSCA Community Kubernetes Profile

This profile defines TOSCA types to support integration with
Kubernetes. It tries to build on and extend existing [TOSCA type
definitions for Kubernetes](inventory.md).

The TOSCA Community Kubernetes Profile defines node types for
Kubernetes resources. Kubernetes resources are the building blocks
used to define, deploy, and manage applications and their underlying
infrastructure within a Kubernetes environment.

## Namespaces
Kubernetes distinguishes between the following two types of resources:

1. *Namespaced Resources*: These exist within a namespace that models
   a *virtual cluster* within a cluster that is used for resource
   isolation.
2. *Cluster-Scoped Resources*: These exist at the cluster level and
   are not tied to any namespace.

This distinction is shown in the following class diagram:
```mermaid
classDiagram
    Resource <|-- ClusterScopedResource
    Resource <|-- NamespacedResource
    ClusterScopedResource <|-- Namespace	
    NamespacedResource "1" --> "0..*" Namespace:ScopedBy
```

## Authentication and Authorization Resources
The main abstractions for managing authentication and authorization
are as follows:

- ServiceAccount: Provides an identity for Pods.
- Role / ClusterRole – Define permissions (RBAC).
- RoleBinding / ClusterRoleBinding – Attach roles to users, groups, or
  service accounts.

The relationships between these abstractions are shown in the
following class diagram:

```mermaid
classDiagram
    Resource <|-- ClusterScopedResource
    Resource <|-- NamespacedResource
    ClusterScopedResource <|-- ClusterRole	
    ClusterScopedResource <|-- Namespace	
    NamespacedResource --> Namespace:ScopedBy
    NamespacedResource <|-- ServiceAccount
    NamespacedResource <|-- Role
    NamespacedResource <|-- Pod
    Pod "1" --> "0..*" ServiceAccount:RunsAs
    Role --> ServiceAccount:RoleBinding
    ClusterRole --> ServiceAccount:ClusterRoleBinding
```
## Storage and Configuration Abstractions

The main storage abstraction in Kubernetes is the *volume*. Kubernetes
volumes provide a way for containers in a pod to access and share data
via the filesystem. There are different kinds of volume that you can
use for different purposes, for example:
- ConfigMap – Stores non-sensitive configuration data (key/value
  pairs, config files).
- Secret – Stores sensitive information (passwords, tokens,
  keys). Mounted into Pods or injected as environment variables.
- PersistentVolume (PV) – A cluster-wide storage resource managed
  independently of Pods.
- PersistentVolumeClaim (PVC) – A Pod’s request for storage, matched
  against available PVs.

Various kinds volumes are shown in the following class diagram:
```mermaid
classDiagram
    Resource <|-- NamespacedResource
    Resource <|-- ClusterScopedResource
    NamespacedResource <|-- Volume
    Volume <|-- PersistentVolumeClaim
    Volume <|-- EmptyDir
    Volume <|-- HostPath
    Volume <|-- ConfigMap
    Volume <|-- Secret
    Volume <|-- Projected
    Volume <|-- Image
    Volume <|-- DownwardAPI
    Volume <|-- Local
    Volume <|-- NFS
    Volume <|-- FibreChannel
    Volume <|-- Iscsi
    NamespacedResource <|-- Pod
    Pod --> Volume:AttachesTo
    ClusterScopedResource <|-- PersistentVolume
    PersistentVolumeClaim --> PersistentVolume:Claims
```

## Workload Abstractions
Kubernetes uses the following abstractions for managing workloads:

- Pod: A Pod is the smallest and most basic deployable unit in
  Kubernetes.  A Pod is a wrapper around one or more containers that
  are tightly coupled and share the same network namespace and storage
  volumes.
- ReplicaSet: Extends pods with scaling and self-healing. It ensures
  that a specified number of Pod replicas are running at all
  times. ReplicaSets recreate Pods if they fail.
- Deployment: Extends ReplicaSets with full lifecycle management,
  including updates and upgrades. It is used to declare desired state
  for stateless apps (number of replicas, rolling updates, rollbacks).
- StatefulSet – Like a Deployment, but for stateful apps that need:
  - Stable identities (network names).
  - Stable storage volumes.
  - Ordered scaling and rolling updates.
- DaemonSet – Ensures a Pod runs on every (or selected) Node. Common
  for monitoring/logging/agent Pods.
- Job – Runs Pods until they complete successfully. Used for batch or
  finite tasks.
- CronJob – Runs Jobs on a schedule (like cron).

Representations of workload abstractions in TOSCA need to address the
following challengs:

- While not recommended, it is possible to instantiate Pods separately
  from ReplicaSets and to instantiate ReplicaSets separately from
  Deployments. This suggests that Pods, ReplicaSets, and Deployments
  should each be modeled using a corresponding TOSCA node type that
  includes the necessary interface operations to support
  Orchestration.
- However, when instantiating a Deployment, Kubernetes automatically
  creates the ReplicaSet for that deployment and the Pods for that
  ReplicaSet. This means that when using TOSCA to *orchestrate* a
  Deployment, the interface operations for the ReplicaSet in the
  Deployment and for the Pods in the ReplicaSet must not be used.
- All Kubernetes workloads are *exposed* to the outside world using
  Service resources (to be discussed next). Independent of the type of
  workload, Service resources always reference the Pods for the
  workload. This means that even when orchestrating a Deployment, the
  TOSCA model for the Deployment must include the Pod node so it can
  be referenced by a Service.

We propose to leverage TOSCA node type inheritance as shown in the
following figure:

```mermaid
classDiagram
    NamespacedResource <|-- Pod
    Pod <|-- Deployment
    Deployment <|-- ReplicaSet
    Pod <|-- StatefulSet
    Pod <|-- DaemonSet
    Pod <|-- Job
    Job <|-- CronJob
```

## Service Abstractions
Workloads are exposed to clients using services. Kubernetes uses the
following service-related abstractions:

- Service – Provides a stable, DNS-resolvable endpoint to a set of
  Pods (via label selectors). Types:
  - ClusterIP (default, internal only).
  - NodePort (exposes on each Node’s IP at a static port).
  - LoadBalancer (uses cloud provider load balancer).
- Ingress – Exposes HTTP/HTTPS routes from outside the cluster to
  Services. Supports routing rules, TLS, etc.

The following class diagram shows a subset of these:
```mermaid
classDiagram
    NamespacedResource <|-- Pod
    NamespacedResource <|-- Service
    NamespacedResource <|-- Ingress
    Ingress --> Service:RoutesTo
    Service --> Pod:Exposes
    Service <|-- ClusterIPService
    Service <|-- NodePortService
    Service <|-- LoadBalancerService
```

## Managing Cluster-Wide Resources

Some Kubernetes resources (e.g., Cluster Roles) are defined
cluster-wide and can be shared and accessed by all Kubernetes services
deployed on the cluster. This section discusses how to model cluster-wide
resources using TOSCA. 
Two potential methods are described:

1. Create-if-not-exists
2. Updates to cluster platform service

### Create-if-not-Exists Nodes

Using the *create-if-not-exists* pattern, TOSCA services that need a
cluster-wide resource include a node template for that resources that
includes both the `select` as well as the `create` directive. TOSCA
Orchestrators process such nodes as follows:

1. The orchestrator first tries to *select* a node from inventory that
   represents the requested cluster-wide resource. This selection may
   optionally involve node filters to identify specific resources,
   e.g., based on property values. If such a node is found, it is used
   in the service.
2. If no such node is found in inventory, the orchestrator *creates*
   the node instead (using the interface operations specified in the
   node template or node type).
3. From there on, other services that request the same cluster-wide
   resource (through their own *create-if-not-exists* node template)
   will be assigned the newly created node.

### Updates to Cluster Platform Service

Marcel suggested modeling the Kubernetes cluster itself as using a
TOSCA service template. Cluster-wide resources would be handled as follows:

- The Kubernetes service template would include one or more node
  templates that represent (shared) cluster-wide resources.

- These node templates use the `count` keyword to specify the number
  of node representations that need to be instatiated based on the
  template.

- When a Kubernetes services needs a new cluster-wide resource, it
  *updates* the Kubernetes platform services by incrementing the
  `count` value for the corresponding nodes and specifying the
  property values for the new resources (presumably by providing them
  as input values to the Kubernetes Platform service).

The user's modeling needs should influence the approach chosen, and
the TOSCA Kubernetes Profile should ideally support both approaches.

