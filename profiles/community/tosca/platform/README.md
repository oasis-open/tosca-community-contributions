# TOSCA Community Platform Profile

This profile defines TOSCA types that support modeling of *platforms*
on which services can be *orchestrated* as well as the *providers* of
these platforms. It builds on and extends existing [TOSCA type
definitions for platforms](inventory.md).

## Platforms

The following figure shows different types of platforms under
consideration:

![Platforms](images/platforms.png)

This figure represents the following:
- Bare Metal: A device without operating system software or firmware
  installed. 
- Compute: A device with operating system software or firmware
  installed.
- IaaS (Infrastructure as a Service): A platform that allows on-demand
  creation of networks, virtual machines and storage
- Container Platform: A container orchestration system such as
  Kubernetes that handles scheduling, scaling, load balancing,
  networking, and self-healing of applications. A Container platform
  sits somewhere between IaaS and PaaS
  - It’s more than IaaS (because it abstracts servers into a unified
    cluster).
  - It’s less than PaaS (because it doesn’t abstract away deployment
    complexity for developers by default).
- PaaS (Platform as a Service): A platform for developing and
  deploying apps. It allows developers to push code and the platform
  handles builds, dependencies, deployment, scaling, etc..  Examples
  of PaaS include
  - Heroku
  - Google App Engine
  - Microsoft Azure App Service
  - AWS Elastic Beanstalk
  - Red Hat OpenShift
- SaaS (Software as a Service): A platform for renting and using a
  finished application. Examples of SaaS include:
  - Gmail
  - Salesforce

> Do we need to call out Serverless/Functions-as-a-Service separately
  or is FaaS just a special type of PaaS?


Based on the [inventory](inventory.md) of node type definitions above,
the following node type hierarchy is proposed:

```mermaid
classDiagram
    class Platform
    Platform <|-- BareMetalPlatform
    Platform <|-- ComputePlatform
    Platform <|-- IaasPlatform
    Platform <|-- ContainerPlatform
    Platform <|-- PaasPlatform
    Platform <|-- SaasPlatform
    IaasPlatform <|-- GoogleCloudPlatform
    IaasPlatform <|-- AwsEc2
    IaasPlatform <|-- OpenStack
    IaasPlatform <|-- Azure
    IaasPlatform <|-- Proxmox
    IaasPlatform <|-- Kubevirt
    ContainerPlatform <|-- KubernetesCluster
    ContainerPlatform <|-- DockerEngine
    PaasPlatform <|-- GoogleAppEngine
    PaasPlatform <|-- AwsBeanstalk
    PaasPlatform <|-- OpenShift
    PaasPlatform <|-- Heroku
    SaasPlatform <|-- Auth0
    SaasPlatform <|-- DBaasPlatform
    DBaasPlatform <|-- AwsAurora
```

### Layering of Platforms

While platform node types are primarily used to create (abstract)
representations of available platform resources, these types can also
be used to *orchestrate* new platform resources. In those cases, newly
orchestrated platform nodes must be *layered* on top of
already-existing platform nodes. This layering is expressed using a
`HostedOn` relationship, and and the corresponding platform node types
must express valid target nodes in their `host` requirement.

The following figures shows three examples of platform layering:

1. It shows a virtual `ComputePlatform` node (a VM) instantiated directly on AWS.
2. It shows a second VM instantantiated on a Proxmox node, which is in
   turn deployed on a physical `ComputePlatform` node (a physical
   server).
3. And finally, it shows a third VM instantiated on Kubevirt, which is
   in turn installed on a Kubernetes cluster.

![Layering of Platforms](images/layering.png)

## Providers and Credentials

This profile also defines node types for modeling the *providers* that
own various platform. The provider is modeled separately from the
platform itself to allow for the fact that different types of
platforms may be offered by the same provider.

> It is a topic of discussion whether *credentials* to access
  platforms should be modeled at this level as well, and if so how
  these credentials should be represented. The discussion below
  assumes there is a separate node type to represent credentials. The
  use of a node type (as opposed to a data type or an artifact) is
  motivated by the fact that credentials may need to be created
  automatically through *orchestration*.

The following figure shows how the various platform-related entities
might interact:

```mermaid
classDiagram
    Platform --> Provider:ProvidedBy
    Platform --> Credential:AuthorizedUsing
    Credential *-- Provider:IssuedBy
```

