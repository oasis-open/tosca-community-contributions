# TOSCA Community Profile Documents

**Related documents:** [profiles README](../README.md) · [meeting-history](../../../../governance/meeting-history.md) · [decision-log](../../../../governance/decision-log.md) · [open-issues](../../../../governance/open-issues.md)

The documents here fall into four kinds, and a document's kind says how long it
lives and what it may claim.

- **Guides** describe what *is*: the methodology, the organization, the
  conventions. They carry no status line because they are always current.
- **Reference** collects material gathered from elsewhere. It is input, not
  guidance, and it goes stale rather than wrong.
- **Domain notes** record why a particular technology is modeled the way it is.
  Durable, but scoped to one subject rather than to the profiles as a whole.
- **Proposals** describe what *should change*. An implemented proposal leaves in
  two directions: the **decision** to the [decision
  log](../../../../governance/decision-log.md), and the **description of what now
  exists** to the README of the profile that declares it. The proposal is then
  deleted, and git carries the argument.

## Guides

- **[design-guide.md](design-guide.md)** — the modeling methodology and the
  design patterns: the Model Continuum and its levels of abstraction, how to
  translate between levels, which operations a node type declares at each level,
  and how abstract services are deployed.
- **[design-patterns.md](design-patterns.md)** — the recurring modeling
  patterns the profiles are built from. Each names a problem that comes up
  across profiles and the type definitions that answer it. Currently the
  Component/Port pattern and the practices built on it.
- **[artifact-conventions.md](artifact-conventions.md)** — how values reach an
  implementation artifact and how results come back: the operation convention,
  the function convention, and what a runtime may be assumed to provide.
- **[profile-organization.md](profile-organization.md)** — where the results
  are kept: the levels and the profiles at each, the two dimensions that decide
  which profile a type belongs in, and the profile naming convention.

## Reference

- **[prior-art.md](prior-art.md)** — a survey of TOSCA type definitions from
  other projects (EDMM, OpenTOSCA, Vintner, DeMAF, Micado, Ystia and others),
  gathered as input for harmonization.

## Domain notes

- **[kubernetes-modeling.md](kubernetes-modeling.md)** — why TOSCA is useful for
  deploying services on Kubernetes, the modeling approaches considered, and the
  questions still open.

## Proposals

- **[abstract-profile-proposed-changes.md](abstract-profile-proposed-changes.md)**
  — proposed enhancements to the abstract profiles: credentials, containment,
  platform and network properties, application interaction, and what `core` is
  for. Section 5 holds what has been raised but not yet worked up.
- **[credential-orchestration-proposal.md](credential-orchestration-proposal.md)** — model
  credentials the orchestrator creates rather than is given: a `Credential` capability, and node
  types for secrets with a lifecycle. The data type half is settled as decision D13.
- **[artifact-calling-convention-proposal.md](artifact-calling-convention-proposal.md)**
  — replace the per-input environment variable convention with a single
  structured document, so an artifact runs unchanged on any orchestrator.
- **[spec-naming-conventions-proposal.md](spec-naming-conventions-proposal.md)**
  — two amendments to §1.2.2 of the specification. This one addresses the OASIS
  TOSCA Technical Committee rather than these profiles.
