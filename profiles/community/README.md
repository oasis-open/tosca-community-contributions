# TOSCA Community Profiles

This directory is intended to track profiles created by the TOSCA
Community.

> The community needs to decide on a naming convention for these
  profiles.

## Objectives
The goal for these community profiles is to combine *best of breed*
type definitions created by various TOSCA projects over the
years. Most of these projects have used the TOSCA Simple Profile type
definitions as a starting point and have extended these definitions to
satisfy project-specific objectives. Since many of these profiles
started with the v1.3 Simple Profile as guidance, it is likely that
there are sufficient similarities between them that should allow them
to be harmonized. However, there are likely also significant
differences, specifically:

- differences in the target platforms on which components modeled by
  node types are intended to be deployed (e.g. IaaS clouds, PaaS
  platforms, Kubernetes clusters, dedicated compute devices, etc.)
- differences in the deployment technologies used to interact with the
  physical resources (e.g., Ansible, Terraform, Bash, etc.)

The community profiles should include sufficient variability to
accommodate these differences.

## Approach

### Inventory

Create an inventory of available TOSCA type definitions based on which
community profiles can be defined. So far, the following have been
identified:

- Vintner
- [Radon particles](https://github.com/radon-h2020/radon-particles):
  Defines TOSCA types for application runtimes, computing resources,
  and FaaS platforms in the form of abstract as well as deployable
  modeling entities. The repository also comprises RADON's FaaS
  abstraction layer that provides several TOSCA definitions to deploy
  a particular FaaS application component to different cloud
  providers.
- EDMM types used by Winery
- Yorc/Ystia
- Ubicity
- xOpera
- other?

> Most of these type definitions need to be converted to TOSCA v2.0

### Categorize

- Distinguish between types that define service components
  vs. types that define the platforms on which these service
  components are deployed.
- Distinguish between abstract types and types that assume specific
  implementations.

### Document

- For each of these categories, document the node type hierarchies.

### Harmonize

- Extract common class hierarchies

### Define Integration Points

- Define common requirement and capability definitions that model the
  integration points between node types.

### Configurations

- Define common properties and attributes that can be used to
  configure nodes and relationships and to track runtime state.

### Implementations

- Attach various implementations to the resulting node type
  definitions.