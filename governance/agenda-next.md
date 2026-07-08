# TOSCA Community — Proposed Agenda (M40, 2026-07-08)

**Status:** Draft agenda for M40, following M39 (2026-07-01)
**Related documents:** [README](../profiles/community/tosca/README.md) · [prior-art](../profiles/community/tosca/prior-art.md) · [design-guide](../profiles/community/tosca/design-guide.md) · [abstract-profile-proposed-changes](../profiles/community/tosca/abstract-profile-proposed-changes.md) · [meeting-history](meeting-history.md) · [decision-log](decision-log.md) · [open-issues](open-issues.md)

Follows up on the M39 decisions and action items. Issue references point to
[open-issues.md](open-issues.md); decision references to
[decision-log.md](decision-log.md). Since M39, Chris has implemented the M39
release-process decision end-to-end on the Ubicity side (CSAR workflow, Sigstore
signing + verification, flat directory structure), so the release item carries
concrete, road-tested input this week.

---

## 1. Action-item review — 10 min
- **Abstract-profile PR** (Chris, *N8*) — platform-specific connection
  properties (management address, credential file, config/access file) on the
  abstract platform types. Status / review.
- **`in_range` PR** (Roberto, *D8*) — re-add `in_range` to `community.tosca.core`
  with the TOSCA v1.3 2-arg `(value, range)` signature. Status / review.
- **Governance docs** — confirm the folder move to the repository top level
  (*P5*); collect review feedback (*I19*: add test info).

## 2. Release process — 20 min · *I8 / R3* — **the main item**
M39 adopted a simple release process (GitHub workflow packaging CSAR artifacts, a
`0.1` release, flat directory structure). Chris has since built exactly this for
the Ubicity profile repos and can share what worked, as a reference for the
community `0.1`:

- **Draft-first flow** — the workflow builds + signs and opens a *draft*
  release; notes are added and it is published deliberately (keeps asset ids
  stable through to publication).
- **Sigstore keyless signing + verification** — CSARs signed via the GitHub
  Actions OIDC identity (cosign), with `verify_release.sh` / `verify_all.sh`
  helper scripts consumers run. Recommend adopting for the community `0.1`.
- **Excluding dependency profiles** — a guard mechanism so a repo's release
  ships only its own profiles, not sibling/upstream deps present only locally.
- **CSAR naming from the `profile:` keyword** — derive the CSAR filename from
  the advertised profile name, not the directory path, so a version bump is a
  one-place edit and flat directories work cleanly.
- **Flat directory structure — confirmed.** Chris wrote an ADR adopting the
  community's flat layout in `tosca-profiles`; it holds up for versioned
  releases (version lives in the `profile:` keyword + the release tag, not the
  path). Reaffirm for the `0.1`.
- **Decide:** target date for the `0.1`; workflow owner; adopt Sigstore signing?

## 3. Single source of truth for shared types — 10 min · *I1 / I15*
With the release process taking shape, revisit whether `Credential`,
`IPv4Socket`, and shared relationship/capability types should be owned solely by
`community.tosca.core`, so downstream profiles **derive** rather than redefine.
(Reinforced by TOSCA's nominal typing — Ubicity hit onboarding failures where
identically-shaped but separately-defined types were treated as incompatible.)

## 4. Open items & AOB — 10 min
- Errata (2.01) status (*I5, I7, I13, I14*); collaborations (*C1–C4*);
  contribution-load / second owners (*I11*).

---

**Decisions sought:** approve the two PRs (#1); lock the `0.1` release plan —
date, owner, and whether to adopt Sigstore signing (#2); reaffirm the flat
directory structure (#2).
