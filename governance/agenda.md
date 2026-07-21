# TOSCA Community — Proposed Agenda (2026-07-22)

**Status:** Draft agenda for 2026-07-22, following 2026-07-15
**Related documents:** [README](../profiles/community/tosca/README.md) · [prior-art](../profiles/community/tosca/docs/prior-art.md) · [design-guide](../profiles/community/tosca/docs/design-guide.md) · [abstract-profile-proposed-changes](../profiles/community/tosca/docs/abstract-profile-proposed-changes.md) · [meeting-history](meeting-history.md) · [decision-log](decision-log.md) · [open-issues](open-issues.md)

Follows up on the 2026-07-15 action items. Issue references point to
[open-issues.md](open-issues.md); decision references to
[decision-log.md](decision-log.md).

---

## 1. Action-item review — 10 min
- **Core data types PR** (Roberto, *D9*) — new `community.tosca.core` types
  (email, URL, FQDN, IPv4 with constraints); submitted? This **gates the `0.1`**
  (see #2–3).
- **Kubernetes consolidation** (Chris, *K6 / I21*) — manual
  `technology.kubernetes` deleted, the auto-generated profile kept, README
  relocated; the `microservice` example repointed to the kept profile.
- **Abstract-profile properties** (Chris, *N8*) — platform connection properties
  (management address, credential file, config/access file) added; ready to
  review.
- **`in_range` test cases** (Chris) — run for `in_range` / `in_range_strict`
  including the new timestamp signature; results.
- **Profile-organization discussion** (Chris, *I22*) — GitHub discussion started
  (`community/tosca` vs `io.kubernetes`); any early input.

## 2. Review Roberto's core data-types PR — 15 min · *D9* — **the `0.1` gate**
- Walk through the proposed types (email, URL, FQDN, IPv4 + constraints) and
  merge, so a standard data-type library is in `core` before the release.

## 3. Cut the `0.1` release — 10 min · *R1 / R3 / R4 / R5 / I8*
- Once the data types (D9) land, cut `0.1` = **`core` + the five `abstract.*`
  profiles** (six files); the technology profiles are held (R5).
- Push the `v0.1` tag → the workflow builds/signs and opens a draft → review +
  publish.

## 4. Profile organization / naming — 10 min · *I22*
- `community/tosca` vs reverse-DNS (`io.kubernetes`); team-designed profiles vs
  broader community contributions. Walk the options + trade-offs in
  [`profile-naming.md`](../profiles/community/tosca/docs/profile-naming.md); note the
  duplicate Kubernetes copies (`io.kubernetes:3.0` vs
  `community.tosca.technology.k8s:0.1`) and the `io.kubevirt`/`sh.helm`
  dependents; steer toward a decision.

## 5. Component/Port modeling resolutions — 10 min · *I16 / I17*
- Proposed resolutions are now drafted in `design-guide.md` and `core/README.md`:
  - **Naming principle** — relationship names express *semantics* (intent), not
    *mechanism* (`ConnectsTo`/`BindsTo` → intent-revealing names).
  - **I16** — declare the capability↔relationship constraint in one place;
    derive-vs-specialize rule.
  - **I17** — formalized monitoring (observability capability + `DependsOn`);
    security split into perimeter / credentials / identity-trust (`RegistersWith`).
  - Category list made explicitly open-ended (adds provisioning, networking, routing).
- Review and ratify, or send back for edits.

## 6. Open items & AOB — 10 min
- Single source of truth for shared types (*I1 / I15*); execution-location gap
  (*I23*) and other errata (*I5, I7, I13, I14*); Windows checkout failure
  (*I20*); contribution-load / second owners (*I11*); Tal's alternative
  Kubernetes auto-generation (incorporate when ready).

---

**Decisions sought:** merge the core data types (#2); cut the `0.1` (#3);
direction on profile organization (#4); ratify the Component/Port resolutions (#5).
