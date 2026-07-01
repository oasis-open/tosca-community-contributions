# TOSCA Community — Proposed Agenda (next meeting)

**Status:** Draft agenda for the meeting following M39 (2026-07-01)
**Related documents:** [README](../profiles/community/tosca/README.md) · [prior-art](../profiles/community/tosca/prior-art.md) · [design-guide](../profiles/community/tosca/design-guide.md) · [abstract-profile-proposed-changes](../profiles/community/tosca/abstract-profile-proposed-changes.md) · [meeting-history](meeting-history.md) · [decision-log](decision-log.md) · [open-issues](open-issues.md)

Follows up on the M39 decisions and action items. Issue references point to
[open-issues.md](open-issues.md); decision references to
[decision-log.md](decision-log.md).

---

## 1. Action-item review — 10 min
- **Abstract-profile PR** (Chris, *N8*) — platform-specific connection
  properties (management address, credential file, config/access file) on the
  abstract platform types. Review the PR.
- **`in_range` PR** (Roberto, *D8*) — re-add `in_range` to `community.tosca.core`
  with the TOSCA v1.3 2-arg `(value, range)` signature. Review the PR.
- **Governance docs** — confirm the folder was moved to the repository top level
  (*P5*); collect the community's review feedback (*I19*: add test info).

## 2. Release process — 15 min · *I8 / R3*
- Status of the **GitHub release workflow** (CSAR artifacts) and the **`0.1`**
  release (targeted for the coming weeks).
- Confirm the flat directory structure holds up for versioned releases.

## 3. Single source of truth for shared types — 10 min · *I1 / I15*
- With a release process taking shape, revisit whether `Credential`,
  `IPv4Socket`, and shared relationship/capability types should be owned solely
  by `community.tosca.core`.

## 4. Open items & AOB — 10 min
- Errata (2.01) status (*I5, I7, I13, I14*); collaborations (*C1–C4*);
  contribution-load / second owners (*I11*).

---

**Decisions sought:** approve the two PRs (#1); confirm the `0.1` release plan (#2).
