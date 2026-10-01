# Modeling Kubernetes Services with TOSCA

**Status:** Design rationale and open questions — carried over from the
hand-authored Kubernetes profile README so it survives the profile's
consolidation (completed 2026-07-22).
**Audience:** TOSCA Community
**Purpose:** Capture *why* TOSCA is useful for Kubernetes, the objectives and
design approaches for modeling Kubernetes services, how Kubernetes coupling maps
onto TOSCA requirements, the cluster-wide-resource patterns, and the open
questions — independent of any single Kubernetes profile. The community's single
Kubernetes resource profile is now the auto-generated `io.kubernetes:1.35`; the
earlier `community.tosca.technology.k8s` and hand-authored
`community.tosca.technology.kubernetes` copies were consolidated away (governance
issues K6 / I21 / I22).

**Related documents:** [README](../README.md) · [modeling-methodology](modeling-methodology.md) · [prior-art](prior-art.md) · [meeting-history](../../../../governance/meeting-history.md) · [open-issues](../../../../governance/open-issues.md)

---

This document captures the community's rationale and design thinking for
modeling Kubernetes services with TOSCA. It builds on and extends existing
TOSCA type definitions for Kubernetes, surveyed in [prior-art.md](prior-art.md)
(see the Micado, Yorc, Ubicity, Puccini, and Turandot sections).

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
   interactions between microservices, a critical feature for
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
2. On the other hand, TOSCA must also maintain the ability to
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

One approach leverages the [model
continuum](modeling-methodology.md#the-model-continuum-in-support-of-abstraction)
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

## From Kubernetes Coupling to TOSCA Requirements

Kubernetes couples resources through several *implicit* conventions — you infer
"what is wired to what" by matching strings across separate manifests. TOSCA
replaces each with an *explicit* typed topology edge, and the Kubernetes profile
then **back-generates** the Kubernetes wiring from that edge:

| Kubernetes coupling | Example | TOSCA edge | How the profile realizes it |
|---|---|---|---|
| **Label selector** | a `Service`/`Deployment` selects Pods via `spec.selector: {app: X}` | `Exposes` / `Controls` (→ `Workload`) | `selector` / `matchLabels` default to the target Pod's `metadata.labels` |
| **Name reference** | a Pod names its `spec.serviceAccountName`; a resource its namespace | `RunsAs` (→ `Identity`); `ScopedBy` (→ `Scope`) | the name field defaults to the target's `metadata.name` |
| **DNS / env var** | a service reaches a peer via `PRODUCT_CATALOG_SERVICE_ADDR=productcatalogservice:3550` | `InteractsWith` (→ `Endpoint`) | the consuming Pod's container `env` is built from each peer's published address |

The explicit edge is the single source of truth; the selector, the name, or the
env var is *generated* from it. This is what makes the topology legible and
checkable at design time — you state the graph instead of reconstructing it from
matching strings.

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
  of node representations that need to be instantiated based on the
  template.

- When a Kubernetes services needs a new cluster-wide resource, it
  *updates* the Kubernetes platform services by incrementing the
  `count` value for the corresponding nodes and specifying the
  property values for the new resources (presumably by providing them
  as input values to the Kubernetes Platform service).

The user's modeling needs should influence the approach chosen, and
the TOSCA Kubernetes Profile should ideally support both approaches.

## Open Questions

### Microservice modeling

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
6. Do we need to support dynamic behavior in service relationships?
7. How does Nephio capture service relationships?

### Where application-level interaction should live

Of the coupling kinds in
[*From Kubernetes Coupling to TOSCA Requirements*](#from-kubernetes-coupling-to-tosca-requirements),
the label-selector and name-reference rows are **resource-to-resource** coupling
— a Kubernetes resource wired to another Kubernetes resource — and the
`io.kubernetes` profile models them directly (`ScopedBy` / `RunsAs` / `Controls`
/ `Exposes`).

The DNS/env row is different in kind. "Microservice A talks to microservice B" is
a **system-view** relationship between *applications* (`InteractsWith` on an
`Endpoint`), not between Kubernetes resources. Yet its Kubernetes realization —
the peer's address injected into the consumer's container `env` — is authored on
the *Pod*, which therefore needs a requirement through which it can read that
address, `{$get_property: [SELF, RELATIONSHIP, <requirement>, CAPABILITY, address]}`.

Two TOSCA facts decide where that requirement comes from:

1. **Requirements are declared on node *types*, not added per node template**, so
   the Pod's requirement needs a Pod type that declares it.
2. **A substitution boundary does not hide the substituted node's relationships.**
   A requirement mapping in the substituting template maps the abstract
   `MicroService`'s `interacts-with` onto a requirement of a node inside the
   substitution, which then takes the outer relationship's target.

Together they allow the interaction to be realized without any type crossing
between levels:

- **The Pod's requirement is a device-view one**: a Kubernetes-level relationship
  to a Kubernetes-level endpoint capability on the peer's `Service`. The generated
  `io.kubernetes` `Service` declares no such capability today, so the realization
  adds one, or the generator does. No system-view type appears in the Kubernetes
  profile.
- **The substituting template for microservice A maps** A's `interacts-with` onto
  that requirement of its Pod.
- **The substituting template for microservice B maps** B's `Endpoint` capability
  onto the endpoint capability of its own `Service`. The Pod's requirement, which
  follows the outer relationship to B, follows B's capability mapping to that
  `Service`, and binds there.
- **The requirement is type-checked where the mapping ends.** The two sides of the
  substitution need not share types; the Pod's requirement must be satisfiable by
  the concrete capability the mapping reaches.

The topology edge stays explicit, at both levels, and no profile mixes levels.

**Ordering.** `InteractsWith` is an association (N11) and orders nothing, while the
Pod needs the peer's address when it is created, so the Pod's requirement is a
dependency. Interactions that form a cycle at the system view would then form a
cycle of dependencies at the Kubernetes level, which cannot be deployed. Whether
that arises in practice, and what the Pod's requirement should declare, is what
realizing the [Online Boutique](../../../../examples/online_boutique/README.md)
with the `io.kubernetes` profile is expected to show.

Two other approaches remain open where this one does not fit:

- **Keep interaction purely at the `MicroService` level** and have the
  substitution translate it into `env` without a requirement on the Pod. This
  needs a way for a substituting template to read the substituted node's
  relationships and turn them into container `env`; without one, the fallback is
  passing peer addresses as plain inputs, which discards the topology edge.
- **Push the injection into the orchestrator**: model the interaction only between
  abstract `MicroService` nodes and have the orchestrator inject the resolved peer
  addresses during substitution. This needs orchestrator support that does not
  exist.

The question generalizes beyond microservices: it recurs whenever a *system-view*
relationship between abstract components must be realized as *configuration* on a
lower-level resource (env vars, connection strings, credentials).
