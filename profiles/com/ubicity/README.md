# Ubicity TOSCA Profiles

This directory contains TOSCA profiles created by [Ubicity
Corp.](https://ubicity.com). They are organized as follows:

- [`com.ubicity:2.0`](2.0/) is the main profile used in many of the
  Ubicity service templates. It has its origins in [TOSCA Simple
  Profile in YAML
  v1.3](https://github.com/oasis-open/tosca-community-contributions/tree/master/profiles/org/oasis-open/simple/1.3)
  but it is more complete and allows for cleaner separation between
  node type implementations from different vendors.

  Ubicity plans to further split up this profile as follows:
  - We will extract a profile with top-level node types that use
    specific technologies but are not tied to specific vendors or
    specific implementations. The resulting profile will strictly be an
    *Administrator View* profile in the [Model
    Continuum](https://github.com/oasis-open/tosca-community-contributions/tree/master/profiles/community/tosca#the-model-continuum-in-support-of-abstraction)
  - We will separate out type definitions that are specific to Docker
    into a `com.ubicity.docker:2.0` profile.
  - We will separate out type definitions for specific software
    packages such as Postgres, Nginx, K3s, etc. into a
    `com.ubicity.apps:2.0` profile.
  - Kubernetes-specific node types have been extracted into
    [`io.kubernetes:2.0`](../../io/kubernetes/2.0/README.md).
- The [`com.ubicity.core:2.0`](core/2.0/) profile defines types and
  functions that are used by many of the other profiles. Ubicity plans
  to phase out this profile and use
  [`community.tosca.core`](https://github.com/oasis-open/tosca-community-contributions/tree/master/profiles/community/tosca/core)
  instead.
- The [`com.ubicity.cloud:2.0`](cloud/2.0/) profile defines abstract
  node types that are intended to be implemented using substitution
  mapping. Example substituting services can be found in the
  [`substitutions`](cloud/2.0/substitutions) directory of the cloud
  profile. Ubicity plans to phase out this profile and replace it with
  the profiles that derive from the
  [`community.tosca.base`](https://github.com/oasis-open/tosca-community-contributions/tree/master/profiles/community/tosca/base)
  instead.
- [`com.ubicity.net:2.0`](net/2.0) is currently a fairly minimal
  profile that was used for demonstrating the creation of VLANs on
  Cisco switches. Ubicity plans to evolve this into a complete profile
  for network management that can be used with a variety of network
  vendors.


