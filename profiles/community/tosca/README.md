# TOSCA Community Profiles

This directory contains TOSCA profiles that are created by the TOSCA
Community&mdash;an informal group of TOSCA implementors and TOSCA
users that meet periodically and collaborate on TOSCA profiles and
examples that can be used by all members. TOSCA community profiles all
use `community.tosca` as their top-level domain name.

## Objectives

The goal for these community profiles is to combine *best of breed*
type definitions created by various [TOSCA projects](inventory.md)
over the years. Most of these projects have used the TOSCA Simple
Profile in YAML v1.3 type definitions as a starting point and have
extended these definitions to satisfy project-specific objectives. As
a result, it is likely that there are sufficient similarities between
these profiles that should allow them to be harmonized. However, there
are likely also significant differences, specifically:

- Differences in the target platforms on which components modeled by
  node types are intended to be deployed (e.g. IaaS clouds, PaaS
  platforms, Kubernetes clusters, dedicated compute devices, etc.)
- Differences in the deployment technologies used to interact with the
  physical resources (e.g., Ansible, Terraform, Bash, etc.)

The community profiles should include sufficient variability to
accommodate these differences.

## Design Patterns

The approach used by the TOSCA Community Profiles leverages the
[policy
continuum](https://github.com/oasis-open/tosca-community-contributions/tree/master/profiles/com/ubicity#abstraction)
design pattern that defines different TOSCA profiles for different
levels of abstraction:

- The [microservices
  profile](../../../profiles/community/tosca/microservices/profile.yaml)
  is a *System View* profile that defines abstract types such as the
  `MicroService` type. These types focus on modeling the microservices
  that make up a service as well as the interactions between these
  microservices. Nodes of these types are used to create abstract
  TOSCA service templates that focus on service topology only and are
  independent of specific implementation details such as service
  meshes or monitoring systems.

- For deployment on Kubernetes, the service template in this directory
  uses types defined in the [microservices
  profile](../../../profiles/community/tosca/microservices/profile.yaml). This
  profile is a *Administrator View* profile that defines node types
  that model Kubernetes resources fairly closely. This profile is
  intended to be augmented with interface operation implementations
  that deploy the corresponding Kubernetes resources on Kubernetes
  clusters.

- TOSCA *Substitution mapping* is used to translate between these two
  views: each node in the abstract service is *decomposed*
  (substituted) using a service template that consists of nodes with
  types defined in the Administrator View profile.

This approach provides service designers with the ability to create
top-down service designs and drill down into lower-level
details. However, tooling support would be necessary to effectively
manage substitution mapping and other complex development processes.

By hiding the internals of each microservice and instead introducing
these internals through substitution, this approach allows each
microservice can be transformed not just into Kubernetes resources,
but also into any other containerized or legacy application, including
Nomad, Docker Compose, serverless, etc.
