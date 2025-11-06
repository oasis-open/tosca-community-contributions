# Substituting Services

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
  model [Kubernetes
  resources](#kubernetes-resources)
  fairly closely. This profile could get augmented with operation
  implementations that deploy the corresponding Kubernetes resources
  on Kubernetes clusters.
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

