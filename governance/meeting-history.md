# TOSCA Community Meetings — History and Analysis

**Status:** Working summary, maintained by the chair
**Scope:** Synthesis of the weekly TOSCA Community meeting summaries
**Related documents:** [README](../profiles/community/tosca/README.md) · [prior-art](../profiles/community/tosca/docs/prior-art.md) · [design-guide](../profiles/community/tosca/docs/design-guide.md) · [abstract-profile-proposed-changes](../profiles/community/tosca/docs/abstract-profile-proposed-changes.md) · [decision-log](decision-log.md) · [open-issues](open-issues.md)

---

## About this record

This document summarizes the weekly TOSCA Community calls (Wednesdays). It is
derived from the per-meeting summaries. A few notes on the source material:

- Early meetings are referenced as **M0** (the first, kickoff meeting) onward,
  following the order of the summaries, which carry no explicit dates. Recent
  meetings are referenced by **actual date** where known — **2026-06-24** (M38),
  **2026-07-01** (M39), **2026-07-08**, and onward.
- Cadence is roughly weekly, with a holiday break around **M14–M15** and a
  return in January at **M16**. That places the kickoff in approximately
  **September 2025**.
- Three summaries are duplicate exports of the same meeting: **M1=M2**,
  **M5=M6**, **M36=M37**. So the ~39 summaries represent ~36 distinct meetings.

---

## The arc — five phases

### Phase 1 — Kickoff and Kubernetes focus (M0–M9)
Established the purpose: build community profiles to replace the normative types
removed in TOSCA 2.0 and make TOSCA usable across application domains. Work
centered on **Kubernetes/TOSCA integration** — the *Online Boutique*
microservices example, service meshes (Istio), and service discovery. Three
modeling philosophies emerged and would recur throughout the series:
- **Tal** — capability types representing Kubernetes resources (assemblages).
- **Chris** — granular node-type + substitution-mapping decomposition.
- **Roberto** — top-down abstraction (application / platform / data).

External collaborators joined: **Westminster** (Jay, Prachi — *Swarmchestrate*),
with **Stuttgart** (Marcel) referenced for EDMM/translation work.

### Phase 2 — Convergence on the abstraction (M10–M15)
Roberto's **three-node model (application / platform / data)** was adopted as the
organizing structure. The profile hierarchy took shape — **core / base /
abstract** — along with the "continuum" design pattern, the JSON
implementation-details convention, and a repository reorganization (profiles vs.
examples). Ended with the pre-holiday break.

### Phase 3 — January return: platform and data modeling (M16–M19)
First proposals for a **management endpoint + credential** (the thread that runs
to M38), **platform layering** (KubeVirt-on-Kubernetes; control-plane vs.
data-plane), and the **six abstract data node types** (at-rest, batch, streaming,
event, API, cache).

### Phase 4 — Deployment, tooling, and conventions (M20–M29)
Live deployment demos (K3s/KubeVirt, multi-flavor Kubernetes clusters, managed
EKS). Naming conventions; `technology`/`vendor`→`product` properties; credential
simplification to file references; abstraction-level **directory restructuring**;
JSON-env-var artifact I/O; relationship-type simplification; and translation
tooling (Redfish, OpenAPI→TOSCA).

### Phase 5 — Contribution, standardization, and release (M30–M39)
TOSCA 2.0 **errata (2.01)** list; `name` property; **Python/bash artifact types**;
function-signature standardization and **portability** (reference
implementations, JSON stdin/stdout protocol, WASM); contributing existing
profiles upstream; and **M38 (2026-06-24)**: the decision that
credential/management-address properties are **specific to each derived platform
type**, plus the **release-process** discussion.

**M39 (2026-07-01)** turned those threads into decisions: proceed with a PR
adding platform-specific connection properties (management address, credential
file, config/access file) to the abstract platform types (Chris); adopt the
**TOSCA v1.3 2-arg `in_range` signature** to ease v1.3→v2.0 upgrades (Roberto to
PR); and adopt a **simple release process** — a GitHub workflow packaging CSAR
artifacts, starting with a `0.1` release — while **keeping the flat directory
structure** (version subdirectories were considered and rejected). The community
also reviewed the new governance docs and agreed to move them to the repository
top level.

**2026-07-08** was an execution check-in. Roberto was out (medical appointment)
but expected to submit the `in_range` signature PR that day; Chris will add the
platform connection properties to the abstract platform types in the community
repo once it merges (sequencing the N8 work behind D8). For release, the
community will **adapt an existing, proven release workflow** (CSAR build +
signing) into the community repo and cut a **stable `0.1` of the core profile by
~2026-07-15**. A
new thrust opened: build **substituting templates that exercise the abstract
profiles**, starting with the (auto-generated) **Kubernetes** profile —
Westminster (Prachi, Jay) will incorporate the Kubernetes profiles and produce a
simple example template (Prachi and Jay meet 2026-07-13 on deployment; Chris to
help with implementation artifacts). Marcel reported his Netherlands dissertation
work is nearing a first paper draft (~a year to completion).

**2026-07-15** (Chris, Roberto). `in_range` / `in_range_strict` are merged, now
with a **timestamp** signature (Roberto). The community **release workflow** was
reviewed — GitHub Actions, tag-triggered (`v*`), packaging each
`community.tosca.*` profile into a signed CSAR via a `TOSCA.meta`-driven build
script (entry-definitions can point at plain TOSCA files, no service template
needed). On the **`0.1` scope (R5)**: ship **`core` + the five `abstract.*`
profiles (six files)**; the technology-specific profiles are held as not yet
mature. **Kubernetes (K6):** delete the hand-authored `technology.kubernetes`
and keep the **auto-generated** profile (more complete, from the OpenAPI),
relocating the manual profile's README into the community repo — Tal is building
a similar auto-generation by a different method, so multiple modeling approaches
stay open. **Core data types (D9):** add a standard library (email, URL, FQDN,
IPv4 with constraints) — Roberto to PR, and **`0.1` is held until it lands**.
Also: Chris to add the platform connection properties (management address) to the
abstract types (N8) for review next week; start a **GitHub discussion** on
profile organization (`community/tosca` vs `io.kubernetes` naming); and a noted
TOSCA gap — no standard way to describe an operation's **execution location** in
service templates.

**2026-09-02** (Chris, Roberto, Stefano), after a two-week break, and the first meeting to work
straight down the [abstract-profile proposal
document](../profiles/community/tosca/docs/abstract-profile-proposed-changes.md). It ran the
full hour and went through all eight of its proposals, agreeing five of them — 2.1, 2.3, 2.4,
2.6 and 2.7 — while 2.2 was already adopted, 2.5 came away reopened and 2.8 was taken
provisionally. Five decisions were recorded, which is a different five: **credentials** as a
reference data type with a per-type key vocabulary (D13, realizing D11); **one containment
requirement name**, `host`, everywhere, with the relationship-type collapse left open and a
warning against constraining capability and relationship both (N9); **never use a base
capability or relationship type directly** (N10), which came out of Roberto asking what a
property-free `Service` capability buys; **one interaction port on `Application`**, replacing
the same-type interactions declared on two of its children (N11); and **`SingleHostApplication`
→ `ServerApplication`** with `processes` dropped, Roberto proposing `implementation-details` as
where such a list would go if it returns (N12). **2.4 is the odd one of the five agreed:** it
carries no decision of its own, being the write-up of N8 from M39, so what 09-02 recorded from
it is the two items it put back in question. Reopened or newly raised: whether `mgmt-address`
should be a URL rather than a structured type (I28) — which reopens the 2026-06-24 resolution;
the container-platform credential vocabulary, agreed to be too Kubernetes-specific (I29);
whether `RelationalDatabase` is a derived type or a `technology` value (I30); an inventory of
storage constructs, Stefano to supply (I31); and orchestrated credentials, Tal's point from
discussion #281, which needs node types rather than a data type (I27). `cidr_block` on
`Network` was taken as-is and openly called provisional, with Roberto proposing `technology`
carry IPv4 / IPv6 / dual-stack instead (I2). Two process outcomes: the agreed changes go into
the **upstream profiles** rather than staying in the document (P6), and Chris expects to bring
an **OPAF/OPAS** participant into the meetings, that profile sitting at the same System View
level for the same vendor-neutrality reason (C4).

**2026-09-09** (Chris, Roberto), a two-person meeting — Damien and Stefano were expected and
neither joined — which decided the one item that was blocking work and postponed the rest rather
than settle them thinly. **The decision is A8: `core` becomes the standard library and the six
base capability and relationship types leave it** for `abstract.base`, with the technology column
declaring its own. The argument that carried it had not been made before, and it is about
interfaces. A relationship type can only be given an interface where the type is declared, so an
interface type for the base relationship types would have to be declared in `core`, putting
technology-specific operations in the profile every other profile imports. And the abstract
profiles cannot use relationship interfaces at all: substitution replaces a node's operations with
workflows on the substituting template, and that mechanism exists for nodes only, so an operation
on an abstract relationship has nothing that can implement it. One profile cannot hold relationship
types serving both columns. N13 had already removed the objection that the six must be shared, so
nothing remained requiring a single definition, and Roberto agreed.

Two questions came out of it. Roberto asked whether the `relationship_kind` metadata is inherited
by derived types (**I44**); it is not — §6.4.2 excludes `metadata` from derivation and §5.3.1 says
metadata may be ignored and should not affect runtime behavior — and the repository already shows
both consequences, `InteractsWith` carrying no kind and the vocabulary differing in case between
`core` and `abstract.base`. Posted as discussion
[#363](https://github.com/oasis-open/tosca-community-contributions/discussions/363). And Roberto raised the portability of `core` itself (**I43**): its
eight functions carry sixteen implementations and every one of them is typed as `Python`, so a
platform that executes custom functions as WebAssembly plugins has to edit the profile to adopt it. The directions raised were splitting
definitions from implementations, or asking TOSCA 2.1 for a profile that can carry alternative
implementations with the orchestrator selecting one — the same problem operations have, where the
choice between Bash, Python, Ansible and Terraform belongs to the orchestrator rather than to the
profile. Roberto to open a discussion.

Chris also walked the **orchestrated-credential** proposal (I27) end to end against a certificate
example, and placed the `Credential` capability type in the technology base profile, orchestration
happening in the technology column and reaching abstract nodes by attribute mapping; Roberto to
review. Everything else on the agenda — `mgmt-address`, the container-platform vocabulary,
`RelationalDatabase`, `control-host`, the three unratified drafts, the artifact calling convention
and the naming amendments — was held for a meeting with fuller attendance. **The chair stated a
target of releasing the `0.1` during September 2026** and announcing it to the community as a
usable deliverable.

*This narrative skips 2026-07-22, 2026-08-05 and 2026-08-12, whose decisions are recorded in
[decision-log.md](decision-log.md) (A7, D10–D12, I26) but were never written up here.*

---

## Cross-cutting themes

| Theme | Evolution across the series |
|-------|------------------------------|
| **Modeling philosophy** | Minimal types + property-based substitution vs. more derived types — the recurring tension. Resolved pragmatically per case; Roberto's top-down abstraction became the backbone. |
| **Credentials / mgmt-address** | ~6-month arc: endpoint capability + credential type (M16) → simplification to file references (M21–M22) → platform-specific, not base-harmonized (M38). |
| **Platform layering** | Server → virtualization → container; KubeVirt/Kubernetes; control-plane vs. data-plane; `kind`/`product` properties to drive substitution; managed clusters lose topology info. |
| **Artifacts & functions** | Bash/Python artifact types; JSON env-var I/O; standardize on a single-module / matching-name / single-arg approach; community impls as reference implementations + JSON stdin/stdout protocol; `integrations/` directory. **2026-09-09:** the portability problem restated as a profile problem — `core` names a `Python` implementation per function, so an orchestrator that runs functions another way must fork the profile (I43). |
| **Spec gaps → errata** | Implementation surfaced TOSCA 2.0 gaps: metadata support, property refinement in data types, artifact-type-mandatory ambiguity, substitution-mapping limits, a proposed `type-of-node` function — feeding a 2.01 errata effort and resumed TC language meetings. |
| **Tooling** | Puccini (TOSCA 2.0 support), OpenAPI→TOSCA generators, Redfish/AnyTOSCA and Ansible translators, visualization (Winery, Inria CloudNet, Mermaid). |
| **Release process** | Surfaced at M38; at **M39** adopted a simple process — a GitHub workflow packaging CSAR artifacts and a `0.1` release, flat directory structure (version subdirectories rejected). **2026-07-08:** adapt an existing, proven release workflow into the community repo; target a stable `0.1` of core by ~2026-07-15. **2026-07-15:** workflow reviewed and in place; `0.1` scoped to `core` + five `abstract.*` (technology profiles held), and held until the new core data types (D9) land. **2026-09-09:** no longer waiting on a design decision, only on the edits; target **September 2026**. |

---

## Participants and roles

- **Chris (chair)** — organizes the meetings; produces most implementations and
  demos; carries the large majority of action items.
- **Roberto** — principal co-designer: top-down abstraction, data node types,
  relationship-type simplification, repo reorganization, `inRange` functions,
  most pull requests.
- **Tal** — Kubernetes/TOSCA integration, Puccini, capability-type modeling,
  OpenAPI→TOSCA generation, Floria/WASM, portability advocacy.
- **Calin** — specification expertise; errata, artifact-type questions, TC
  coordination.
- **Marcel (Stuttgart)** — EDMM, Ansible/Terraform translation, node-placement
  scenarios, the system/admin/device-view organizing principle.
- **Angelo / Domenico** — abstraction simplification, Kubernetes cluster
  provisioning, ingress.
- **Jay & Prachi (Westminster)** — *Swarmchestrate*; OpenAPI→TOSCA tooling.
- **Stefano** — infrastructure reverse-engineering and visualization; CloudNet
  tools. **Mohamed (Telefonica)**, **Paul Jordan** (spec test cases) — newer
  / peripheral contributors.

---

## Recurring patterns

- The series is **implementation-driven**: nearly every design decision was
  validated by building it (Online Boutique, K8s cluster deployment, multi-cloud
  service templates), and most open spec issues were discovered that way.
- After the completion of TOSCA v2, the community's stated posture is
  **adoption over new functionality** — profiles, examples, and tooling rather
  than language changes (with errata handled separately).
- The **abstract-profile credential/mgmt-address work** that culminated at M38 is
  documented in detail in
  [abstract-profile-proposed-changes.md](../profiles/community/tosca/docs/abstract-profile-proposed-changes.md).
- Process observations (e.g. contribution-load distribution) are tracked as
  action items in [open-issues.md](open-issues.md).
