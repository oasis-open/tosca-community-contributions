# TOSCA MicroServices Profile

This profile defines TOSCA types that support the deployment of
microservices. These microservices will typically be deployed on
Kubernetes clusters, although other deployment platform can be
considered as well.

## Why TOSCA for Deploying Services on Kubernetes

Since TOSCA models services as a graph, it contains **service
topology** information that represents how various microservices
interact with one another to deliver complete system
functionality. Such service relationships and dependencies are not
immediately apparent from Kubernetes manifests.

Service topology information enables a variety of automation use
cases:

1. *Service Visualization*: TOSCA provides solution architects with a
   powerful tool for designing applications by visualizing
   interactions between microservices, a critial feature for
   designing complex applications.
2. *Design-Time Validation*: Using TOSCA for modeling Kubernetes
   services provides the ability to validate topological relationships
   between microservices at design time, ensuring correct designs
   before service deployment.
3. *Runtime Validation*: TOSCA can also be used for Day 2
   validation. TOSCA templates effectively define a collection of
   schemas and policies that apply not only at deployment but also
   during ongoing operations. Orchestrators can validate at runtime
   whether a service complies with its TOSCA template and take
   corrective action if not.
4. *Microservice Configuration*: Topology information can be used to
   automatically generate microservice configurations such as resource
   labels and selectors, connectivity information (e.g., using
   environment variables), etc.
5. *Deploy Service Meshes*: Automatically *inject* service meshes
   (such as Istio, Linkerd, Consul, and others) into Kubernetes
   services and use topology information to configure these meshes.
6. *Enforce Network Policies*: By default, Kubernetes microservices
   use a single Layer 2 network that enables any-to-any communication
   between microservices and does not enforce any security
   rules. Topology information in TOSCA service templates can be used
   to only enable connectivity between those microservices that are
   expected to communicate (e.g., by deploying and configuring Cillium
   network security and packet filtering).
7. *Manage Deployment Dependencies*: Some Kubernetes resources may
   need to be created before others. For example, some resources
   require an *admin* service account before a namespace can be
   created. This type of *precedence* relationship cannot be expressed
   in Kubernetes manifests and may require separating manifests.
8. *Model Relationships between Infrastructure and Workloads*: TOSCA
   offers the potential to streamline Kubernetes deployments by using
   TOSCA as a unified language for infrastructure and workload
   management, which could simplify the deployment process and ensure
   proper interaction between infrastructure and workloads.
9. *Improved Service Assurance*: TOSCA provides the ability to create
   additional control loops for service assurance, particularly when
   dealing with unreliable software and hardware.

## Objectives

TOSCA support for deploying microservices on Kubernetes is guided by
the following two (seemingly competing) objectives:

1. Given that TOSCA's main benefit is its ability to define service
   topologies that model the interactions between microservices, it
   must support **top-down** service designs that abstract away
   non-essential details to maintain a clear focus on microservice
   interactions.
2. On the other hand, TOSCA must also maintaining the ability to
   express low-level Kubernetes concepts and support **bottom-up**
   designs that align with Kubernetes resources, as losing this
   functionality could create obstacles for existing Kubernetes users.

TOSCA profiles for microservices on Kubernetes must balance high-level
abstractions with low-level building blocks since users might need
both approaches depending on their workflows and company requirements.

## Design Approaches

The following two approaches are explored to balance high-level
microservice abstractions with low-level Kubernetes resource
descriptions:

### Substitution Mapping

One approach leverages the [policy
continuum](https://github.com/oasis-open/tosca-community-contributions/tree/master/profiles/com/ubicity#abstraction)
design pattern that defines different TOSCA profiles for different
levels of abstraction:

- A *System View* profile defines abstract types that focus on
  modeling the microservices that make up a service and the
  interactions between these microservices. Nodes of these types are
  used to create abstract TOSCA service templates that focus on
  service topology only and are independent of specific
  implementation details such as service meshes or monitoring
  systems.
- A separate *Administrator View* profile defines node types that
  model Kubernetes resources fairly closely. This profile could get
  augmented with operation implementations that deploy the
  corresponding Kubernetes resources on Kubernetes clusters.
- *Substitution mapping* is used to translate between these two views:
  each node in the abstract service is *decomposed* (substituted)
  using a service template that consists of nodes with types defined
  in the Administrator View profile.

This approach provides service designers with the ability to create
top-down service designs and drill down into lower-level
details. However, tooling support would be necessary to effectively
manage substitution mapping and other complex development processes.

By hiding the internals of each microservice and instead introducing
these internals through substitution, this approach allows each
microservice can be transformed not just into Kubernetes resources,
but also into any other containerized or legacy application, including
Nomad, Docker Compose, serverless, etc.

### Microservice Node Types with Kubernetes Resource Capability Types

A second approach balances the objectives outlined above by using
*node types* to represent the microservices in a Kubernetes service
and using *capability types* to represent the Kubernetes resources
that implement those microservices:
- The TOSCA profile for Kubernetes defines capability types that model
  Kubernetes resources fairly closely.
- The same profile also defines a base microservice node type.
- Node types that derive from the base microservice node type define
  capabilities that model the Kubernetes resources that are used to
  deploy nodes of this derived type.

Using this approach, all definitions required to deploy TOSCA services
on Kubernetes are in one place, simplifying design and reducing
tooling challenges.

### Questions

1. Service meshes can be added to any microservices-based
   application. How do we represent in the TOSCA service template
   whether the Kubernetes service needs a service mesh or not?
   Different node types in the MicroServices profile? Different
   `MicroService` node properties?
2. Different types of service meshes can be added (e.g., Istio,
   Linkerd, etc.). How do we represent which service mesh is used?
   Different node types in the MicroServices profile? Different
   `MicroService` node properties?
3. Configuring network security and network policies requires a CNI
   like Cillium. How do we represent which CNI is used? Is this
   modeled as part of Platform node type?
4. Do we need to define a standard architecture for applications to
   avoid variability in configuring connectivity information? For
   example, in the example manifest file for the Online Boutique, we
   can figure out which services interact with which other services
   based on the values of environment variables. Environment value
   configurations are specific to the application and not understood
   by Kubernetes, requiring custom mechanisms for TOSCA templates to
   represent them. Do we need to come up with a *standard* approach
   for representing this?
5. What other common approaches are typically used for configuring
   communication between microservices?
6. Do we need to support dynamic behavior in service relationships.
7. How does Nephio capture service relationships.

