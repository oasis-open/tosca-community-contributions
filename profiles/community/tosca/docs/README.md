# TOSCA Community Profile Documents

**Related documents:** [profiles README](../README.md) · [meeting-history](../../../../governance/meeting-history.md) · [decision-log](../../../../governance/decision-log.md) · [open-issues](../../../../governance/open-issues.md)

The documents here fall into four kinds, and a document's kind says how long it
lives and what it may claim.

- **Guides** describe what *is*: the methodology, the organization, the
  conventions. Their status is always *current practice*. A guide may also carry
  a proposed amendment to itself, marked by a callout that names its tracker
  issue; when the issue is decided the callout goes, and the text either stays as
  current practice or goes with it.
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

- **[modeling-methodology.md](modeling-methodology.md)** — the Model Continuum
  and its levels of abstraction, how to translate between levels, which
  operations a node type declares at each level, and how abstract services are
  deployed.
- **[design-patterns.md](design-patterns.md)** — the recurring modeling
  patterns the profiles are built from. Each names a problem that comes up
  across profiles and the type definitions that answer it.
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
  — the proposals for the abstract profiles that are still open: one containment
  requirement and the control-plane requirement, the platform connection
  properties, and the application placement change that follows from the first.
  A proposal leaves the document once it is written into the profiles.
- **[credential-orchestration-proposal.md](credential-orchestration-proposal.md)** — model
  credentials the orchestrator creates rather than is given: a `Credential` capability, and node
  types for secrets with a lifecycle. The data type half is settled as decision D13.
- **[artifact-calling-convention-proposal.md](artifact-calling-convention-proposal.md)**
  — replace the per-input environment variable convention with a single
  structured document, so an artifact runs unchanged on any orchestrator.
- **[spec-implementation-binding-proposal.md](spec-implementation-binding-proposal.md)**
  — a construct for supplying an implementation for a function or an operation
  declared elsewhere, and for choosing among several. Also addressed to the OASIS
  TOSCA Technical Committee.
