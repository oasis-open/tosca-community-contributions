# TOSCA Community Common Profile

The Common profile defines types for modeling services and
applications at the highest level of abstraction. It also defines
types to represent the platforms on which these services and
applications are deployed. 

## Node Types
At the highest level of abstraction, a service or application can be
modeled using the service template shown in the following figure:

![Applications, Data, and Platforms](images/applications_vs_platforms.png)

This service template defines three nodes:

1. An *application* node of type `Application` that represents the
   functionality provided by the service.
2. A *data* node of type `Data` that represents the persistent data
   processed by the service. This data node can model Data Sets, Data
   Lakes, Databases or similar entities.
3. A *platform* node of type `Platform` that represents the platform
   on which the service is deployed.

Each of these nodes is defined as abstract using the `substitute`
directive and is intended to be implemented using *substitution
mapping*.

## Relationship Types

The nodes in the service template above relate to one-another using
the following relationships:

- Application nodes define a relationship of type `RunsOn` to a
  platform node. This is a containment relationship that defines which
  platform runs the application.
- Application nodes define a relationship of type `Processes` to a
  node node. This is a dependency relationship that defines which
  entity contains the data that are processed by the application.
- Application nodes define a relationship of type `AvailableOn` to a
  platform node. This is a containment relationship that defines which
  platform stores persistent copies of the data.

## Substitutions

The abstract nodes in the Service Template shown above are intended to
be decomposed into concrete Service Templates using the TOSCA
substitution mapping mechanism. This approach can be used to
orchestrate both the infrastructure and the application. For example,
a TOSCA Orchestrator may build a service from scratch by:

- First setting up a K8s cluster, and then
- Deploying a service on the newly created K8s cluster

The substituting templates can use one or more levels of derivation
down to the lowest level (the Instance View in the Policy
Continuum) by defining the appropriate profiles as follows:

- Separate profiles are needed to model Applications and Platforms.
- Another Profile may be needed to represent types that are common to
  both templates.
- Additional profiles may be needed for specific technologies/devices.
