# TOSCA Profile Design Patterns

Ubicity uses a several design patterns to help guide the development
of TOSCA profiles. These patterns are described in this document.

## Abstract Service Design

Ubicity leverages abstraction in service design using the following
process:

1. Create technology-independent service designs.
2. Create representations for available platforms.
3. Make placement decisions based on abstract representations of
   services and platforms.
4. Create substituting services based on selected platforms.

### Create Technology-Independent Service Designs
- High-level service designs should be *abstract and portable* and
  should be independent of the target platform on which the service
  will ultimately be deployed.
- Abstract service designs should show the functional architecture of
  the system: what are the system components and how do they interact?
- Abstract service designs should be modeled using an *Administrator
  View* profile that is technology-independent.
- Each component in the functional architecture should specify the
  requirements for capabilities in the target platform(s) on which the
  service can be deployed.

The following shows a hypothetical example of an abstract service that
provides a context-aware personal assistant:

![Technology Independent Service Design](images/service-design.png)

### Create Technology-Independent Representations for Available Platforms

Orchestrators should maintain representations of the available
platforms on which services can be deployed.

- Platforms should be modeled using an *Administrator View* profile,
  since we are not concerned with details about the internals of the
  platforms.
- Instead, representations for the available platforms should contain
  just enough information to allow Orchestrators to make intelligent
  orchestration decisions (e.g. placement decisions). This information
  should include the following:
  - Location: where is the platform physically located?
  - Capabilities: what type of platform is it and what types of
    workloads can the platform support?
  - Capacity: how much load can be placed on the platform?
  - Access: how to access the platform?

The following shows a representation of the platforms available for a
specific customer. 

![Available Platforms](images/platforms.png)

### Make Placement Decisions

When deploying an abstract service, the Orchestrator first makes
placement decision by *fulfilling* the dangling requirements of the
nodes in the abstract service representation using capabilities of the
nodes in the abstract platform representations. Node filters can be
used to narrow down the set of candidate target platforms. The
following example shows a node filter that drives placement for the
`analytics` node in the abstract service template.

the following figure:

![Placement Decisions](images/placement.png)

### Substitute Based on Allocated Target Platform

Once placement decisions have been made, the Orchestrator finds
substituting templates that are suitable for the allocated target
platform. This is done by using information about that target platform
into the substitution filters for the candidate substituting
templates.

> If substitution decisions made based on the type of the allocated
  platform, do we need to define a TOSCA function that returns a node
  type?

#### Substitute for Kubernetes

The following figure shows an example where the abstract service is
deployed on a Kubernetes cluster.
![Placement on Kubernetes](images/placement-gke.png)

This information is then used to substitute the abstract nodes with
substituting templates that implement those nodes by deploying
Kubernetes resources. TOSCA type definitions from the TOSCA Kubernetes
Profile are used for the templates in the substituting service:

![Substitution for Kubernetes](images/substitution-k8s.png)

#### Substitute for Amazon Web Services

The following figure shows an alternative deployment on Amazon EC2:
![Placement on Amazon](images/placement-aws.png)

In this scenario, abstract nodes are substituted using templates that
implement those nodes by deploying infrastructure on AWS and
installing the necessary software components on that
infrastructure. TOSCA type definitions from the TOSCA AWS Profile are
used for the templates in the substituting service:

![Substitution for Amazon](images/substitution-aws.png)

## Component/Port Pattern

TOSCA uses a **Component/Port** pattern where a component’s touch
points for interacting with other components are modeled separately
from that component using *port* abstractions. Using TOSCA, components
are modeled using *Node Types* and the ports of those components are
modeled using the following two different abstractions associated with
node types:
- Capabilities: for functionality exposed by a component and usable by
  other components.
- Requirements: for dependencies of one component on functionality
  exposed by other components.

The Ubicity Component/Port pattern defines *common* categories of
functionality that are typically exposed by all components. It then
attempts to define *common* capability types and *common* relationship
types to represent each of these categories of functionality. Note
that this pattern is inspired by the [ONF Core Information
Model](https://opennetworking.org/software-defined-standards/models-apis/),
the [TMF Open Digital Architecture](https://www.tmforum.org/oda/), and
other modeling efforts that use a similar approach. These standard
categories of functionality are shown in the following picture:

![Component/Port Pattern](images/component-port.png?raw=true)

- **Runtime environment**: most if not all TOSCA nodes are contained
  by (*hosted on*) another node and their lifecycle is determined by
  the lifecycle of the containing node. This containment dependency is
  expressed using an *execution environment requirement* that must be
  fulfilled by a corresponding *execution environment capability* of
  the containing node. Nodes that can *host* other nodes typically
  have their own *runtime environment requirement*.
- **Core functionality**: the main function of a TOSCA node is to
  provide a specific set of features or functionality to other
  nodes. This is expressed using a *core functionality
  capability**. Other nodes will define requirements for this
  functionality.
- **Management**: many TOSCA nodes are matched with a corresponding
  management tool. This relationship is expressed as a *management
  requirement* of the managed TOSCA node rather than as a *management
  capability* to express potential deployment dependencies: if the
  management tool is used to configure the TOSCA node, the management
  tool must be deployed before the managed node can be fully deployed.
  Note that for management tools, the management functions are exposed
  as their *core functionality capability*.
- **Monitoring**: many TOSCA nodes are matched with a corresponding
  monitoring tool. This relationship is expressed as a *monitoring*
  capability of the monitored node.

  > This pattern was discussed in the TOSCA TC but never formalized.

- **Security**: access to TOSCA nodes may need to be secured.

  > This pattern needs further work

As stated earlier, Ubicity uses this pattern to define common
capability types and common relationship types for these various
categories of functionality. These types are discussed next.

### Best Practices
Best practices questions:

- Specific relationship types may need to get matched with specific
  capability types. This constraint can be specified:
  - Just in the relationship type using the `valid_capability_types`
    keyword.
  - Just in the capability type using the `valid_relationship_types`
    keyword.
  - In both places.

  Which one is the best way to go?

- How deep do we make the relationship type and capability type
  hierarchies? Or, said a different way, when is it appropriate to
  define new derived relationship and/or capability types? We should
  consider the following scenarios:

   1. Derived type names can more clearly indicate the intended
      function of the relationship or capability and improve
      *readability* of profiles and templates.
   2. Additional properties and/or attributes need to be defined for
      relationships or capabilities.
   3. Additional inputs and/or operation implementations need to be
      defined for relationship interfaces.
   4. Additional interfaces need to be defined on relationships.

- If specific capabilities are needed, and specific relationships to
  those capabilities are needed, there are two ways to define these:

   1. We can create derived capability types and associated
      relationship types and use those types in requirement and
      capability definitions.
   2. We can use the base types as-is, and *specialize* how they can
      be used in capability and requirement definitions using the
      `valid_source_node_types` and `valid_target_node_types`
      keywords.

  Which one is the best way to go?
