# TOSCA Community Profiles

**Related documents:** [design-guide](design-guide.md) · [prior-art](prior-art.md) · [abstract-profile-proposed-changes](abstract-profile-proposed-changes.md) · [meeting-history](governance/meeting-history.md) · [decision-log](governance/decision-log.md) · [open-issues](governance/open-issues.md)

This directory contains TOSCA profiles that are created by the TOSCA
Community&mdash;an informal group of TOSCA implementors and TOSCA
users that meet periodically and collaborate on TOSCA profiles and
examples that can be used by all members. TOSCA community profiles all
use `community.tosca` as their top-level profile name.

## Objectives

The goal for the TOSCA Community profiles is to combine *best of
breed* type definitions created by various [TOSCA
projects](prior-art.md) over the years. Most of these projects have
used the TOSCA Simple Profile in YAML v1.3 type definitions as a
starting point and have extended these definitions to satisfy
project-specific objectives. As a result, it is likely that there are
sufficient similarities between these profiles that should allow them
to be harmonized. However, there are likely also significant
differences, for example:

- Differences in the *level of abstraction* at which services are
  modeled.
- Differences in the *target platforms* on which components modeled by
  node types are intended to be deployed (e.g. IaaS clouds, PaaS
  platforms, Kubernetes clusters, dedicated compute devices, etc.)
- Differences in the *deployment technologies* used to interact with
  the physical resources (e.g., Ansible, Terraform, Bash, etc.)

The TOSCA Community profiles are intended to harmonize these various
profiles while at the same time allowing sufficient variability to
accommodate these differences. With these goals in mind, the TOSCA
Community follows the guidelines described in the [design
guide](design-guide.md).

## Documents in this directory

- **[design-guide.md](design-guide.md)** &mdash; the modeling
  methodology (the Model Continuum and its abstraction levels,
  translating between levels, and deploying abstract services) together
  with the TOSCA Community design patterns (the Component/Port pattern).
- **[prior-art.md](prior-art.md)** &mdash; a survey of existing TOSCA
  type definitions from other projects, gathered as input for
  harmonization.
- **[abstract-profile-proposed-changes.md](abstract-profile-proposed-changes.md)**
  &mdash; a specific proposal to extend the abstract platform and data
  profiles (management address, credentials, and related issues).
- **[governance/](governance/)** &mdash; community-process documents:
  the [meeting history](governance/meeting-history.md), the [decision
  log](governance/decision-log.md), and the [open-issues
  tracker](governance/open-issues.md).

## Profiles

The profiles themselves live in subdirectories of this directory (for
example the `core` profile and the `abstract` profiles). See the
[design guide](design-guide.md) for how these profiles map onto the
levels of the model continuum.
