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

