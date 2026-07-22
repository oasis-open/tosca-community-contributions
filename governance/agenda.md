# TOSCA Community — Proposed Agenda (2026-07-29)

**Status:** Draft agenda for 2026-07-29, following 2026-07-22
**Related documents:** [README](../profiles/community/tosca/README.md) · [prior-art](../profiles/community/tosca/docs/prior-art.md) · [design-guide](../profiles/community/tosca/docs/design-guide.md) · [profile-naming](../profiles/community/tosca/docs/profile-naming.md) · [kubernetes-modeling](../profiles/community/tosca/docs/kubernetes-modeling.md) · [open-issues](open-issues.md)

Follows up on the 2026-07-22 action items. Issue references point to
[open-issues.md](open-issues.md).

---

## 1. Action-item review — 10 min
- **Core data types** (Roberto, *D9*) — email, FQDN, and HTTP URL types **merged**
  into `core`; the `0.1` gate is cleared (see #2).
- **Kubernetes consolidation** (Chris, *K6 / I21 / I22*) — **done**: a single
  Kubernetes resource profile, `io.kubernetes:1.35`; the `technology.k8s` and
  hand-authored `technology.kubernetes` copies deleted; `technology/README.md`
  points to the kept profile; the `microservice` example repointed. Confirm closed.
- **Abstract-profile platform properties** (Chris, *N8*) — connection properties
  (management address, credential file, config/access file) for how an
  orchestrator reaches a platform; status.
- **Tal's OpenAPI→TOSCA generator** (Roberto) — a submission location suggested;
  is the PR in, and when do we review it (see #5)?

## 2. Cut the `0.1` release — 15 min · *R1 / R3 / R4 / R5 / I8* — **the main item**
- With the core data types merged (#1), cut `0.1` = **`core` + the five
  `abstract.*` profiles**; the technology profiles are held (R5).
- Push the `v0.1` tag → the workflow builds/signs and opens a draft → review +
  publish. This gives the community a stable baseline to work from.

## 3. Kubernetes profile testing & feedback — 10 min
- First feedback from **Prachi and Jay** testing `io.kubernetes:1.35`; issues,
  gaps, and what to fix before broader use.

## 4. Kubernetes application-level modeling — 10 min
- Open design question in
  [`kubernetes-modeling.md`](../profiles/community/tosca/docs/kubernetes-modeling.md):
  where **application-level** (microservice-to-microservice) interaction should
  live, given the substitution boundary and that requirements are declared on
  types. Walk the options and gather direction.

## 5. Tal's alternative Kubernetes generation — 5 min
- Review Tal's separate automated OpenAPI-to-TOSCA approach and where it lands in
  the repo; schedule a PR walkthrough in a future meeting. Keep room for multiple
  modeling approaches.

## 6. Component/Port modeling resolutions — 10 min · *I16 / I17*
- Carry-over: ratify the drafted resolutions in `design-guide.md` /
  `core/README.md` — intent-based relationship naming; where to declare the
  capability↔relationship constraint; formalized monitoring (observability +
  `DependsOn`) and security (perimeter / credentials / identity-trust).

## 7. Open items & AOB — 10 min
- OPAS / Margo end-to-end demo (container-based deployment to edge devices) —
  schedule for a future meeting.
- Single source of truth for shared types (*I1 / I15*); errata (*I5, I7, I13,
  I14, I23*); Windows checkout failure (*I20*); contribution-load / second
  owners (*I11*).

---

**Decisions sought:** cut the `0.1` (#2); ratify the Component/Port resolutions (#6).
