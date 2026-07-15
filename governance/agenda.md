# TOSCA Community — Proposed Agenda (2026-07-15)

**Status:** Draft agenda for 2026-07-15, following 2026-07-08
**Related documents:** [README](../profiles/community/tosca/README.md) · [prior-art](../profiles/community/tosca/prior-art.md) · [design-guide](../profiles/community/tosca/design-guide.md) · [abstract-profile-proposed-changes](../profiles/community/tosca/abstract-profile-proposed-changes.md) · [meeting-history](meeting-history.md) · [decision-log](decision-log.md) · [open-issues](open-issues.md)

Follows up on the 2026-07-08 action items. Issue references point to
[open-issues.md](open-issues.md); decision references to
[decision-log.md](decision-log.md).

---

## 1. Action-item review — 10 min
- **`in_range` — done** (Roberto, *D8 / I18*, PR #348) — the 2-arg
  `(value, [min, max])` signature was applied to **both `in_range` and
  `in_range_strict`**, with integer/float/string/timestamp/version overloads.
- **Release workflow — done** (Chris, *R4 / I8*) — a GitHub Actions release
  workflow (`build_csars.sh` + cosign signing + verify helpers), validated
  end-to-end in a fork (built + signed + verified all nine CSARs) and **merged**
  upstream. Ready to cut the `0.1` (see #2, #4).
- **Abstract-profile properties** (Chris, *N8*) — unblocked by the `in_range`
  merge; status of adding the platform connection properties (management
  address, credential file, config/access file) to the abstract platform types.

## 2. `0.1` release scope — all nine profiles, or core + abstract only? — 15 min · **decision** · *R1 / R3 / R4 / I8*

With the workflow ready, decide **what the stable `0.1` ships**:

- **All nine** — `core`, the five `abstract.*`, and the three `technology.*`
  (`base`, `k8s`, `kubernetes`).
- **Core + abstract only (six)** — `core` +
  `abstract.{base, platform, application, data, network}`, holding the three
  `technology.*` profiles for a later release.

**For discussion:**

- The `abstract.*` layer is the design-stable model continuum (application /
  platform / data / network, over `base`) the community converged on. The
  `technology.*` profiles are more implementation-oriented — `technology.k8s`
  is auto-generated from the Kubernetes OpenAPI — and the substituting-template
  validation that exercises them (K5 / I21) is still in progress.
- R1 / R4 framed `0.1` as a **stable** cut centered on the **core** profile; a
  core+abstract release tells a clean "here is the abstract model" story and
  lets the technology profiles follow in `0.2` once the substitution work
  proves them.
- Counter-view: the technology profiles (especially Kubernetes) make the
  abstractions concrete and immediately usable; excluding them may weaken the
  release's utility.
- **Tooling note:** the build auto-discovers and packages all nine via their
  `TOSCA.meta`; a core+abstract decision means scoping the discovery to exclude
  `technology/`.

**Decision sought:** the `0.1` profile set.

## 3. Kubernetes modeling — keep hand-authored `technology.kubernetes` alongside the auto-generated `k8s`? — 10 min · feeds #2

Both profiles model Kubernetes **resources**, but with different philosophies —
and current usage cuts against the obvious assumption that the generated profile
supersedes the hand-authored one:

- **`community.tosca.technology.kubernetes:0.1`** (hand-authored, ~50 types) — a
  curated resource hierarchy (`Resource` → cluster/namespaced →
  `Pod`/`Deployment`/`Service`/`ConfigMap`/`Role`/…) with TOSCA **relationships
  and service-topology** semantics (design-time validation, visualization — the
  value-add its README argues). **Used** by
  `examples/substitutions/microservice/`.
- **`community.tosca.technology.k8s:0.1`** (auto-generated, ~324 types) — a 1:1
  mirror of the Kubernetes OpenAPI. Comprehensive but flat, no topology
  semantics, and **imported by nothing** in the community set.
- **`io.kubernetes:3.0`** — the same generated model as `k8s` under another name;
  **used** by the vendor-side profiles (`com.ubicity.kubernetes`, `sh.helm`,
  `io.kubevirt`), and lives outside `profiles/community/tosca/`.

**The question:** the generated model gives comprehensive API coverage but no
topology; the hand-authored one gives topology + substitution (TOSCA's
differentiator) but is curated and incomplete. Which does the community carry —
the topology-rich `technology.kubernetes`, the comprehensive `k8s`, or both
(e.g. `kubernetes` layering topology over the generated types)? Usage today
favors `technology.kubernetes` (a working example; `technology.k8s` has no
importers). This is a concrete instance of the recurring minimal/curated-vs-
generated modeling tension.

**Decision sought:** which Kubernetes profile(s) the community keeps and
publishes.

## 4. Cut the stable `0.1` — 10 min · *R1 / R3 / R4 / I8*
- Once the scope (#2) is set, push the `v0.1` tag → the workflow builds/signs
  and opens a draft release → review + publish.
- Consumers verify artifacts with the `verify_*.sh` scripts.

## 5. Substituting templates exercising the abstract profiles — 10 min · *K5 / I21*
- Chris's Kubernetes substitution template (exercising the abstract platform
  types); Westminster readout — Prachi's example template and the 2026-07-13
  Prachi/Jay deployment discussion.

## 6. Open items & AOB — 5 min
- Single source of truth for shared types (*I1 / I15*); errata (2.01) status
  (*I5, I7, I13, I14*); Windows checkout failure (*I20*); contribution-load /
  second owners (*I11*).

---

**Decisions sought:** the `0.1` profile set (#2) and the canonical Kubernetes
profile(s) (#3); confirm the `v0.1` tag/publish plan (#4).
