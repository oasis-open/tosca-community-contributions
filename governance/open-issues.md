# TOSCA Community — Open Issues Tracker

**Status:** Working tracker, maintained by the chair
**Related documents:** [README](../profiles/community/tosca/README.md) · [prior-art](../profiles/community/tosca/docs/prior-art.md) · [design-guide](../profiles/community/tosca/docs/design-guide.md) · [abstract-profile-proposed-changes](../profiles/community/tosca/docs/abstract-profile-proposed-changes.md) · [meeting-history](meeting-history.md) · [decision-log](decision-log.md)

Unresolved questions and work-in-progress from the weekly TOSCA Community
meetings. Older meetings are referenced by number; recent meetings by **date**
(see [meeting-history.md](meeting-history.md)). Once an item is settled it moves
to the [decision-log.md](decision-log.md).

Status legend: 🔴 open · 🟡 in progress · 🔵 needs a TC / spec decision

---

## Profiles & types

| # | Issue | Status | Owner | Next step |
|---|-------|--------|-------|-----------|
| I1 | **Single source of truth for shared types.** Should `Credential`, `IPv4Socket`, etc. be owned solely by `community.tosca.core`, with other profiles importing rather than redefining them? Duplicate definitions are incompatible under TOSCA nominal typing. (Q3 of the abstract-profile doc.) | 🔴 | Community | Decide ownership; depends on a release process (I8). |
| I2 | **Generic networking / subnet model** for container networks is missing. | 🔴 | Chris | Propose a generic subnet model. |
| I3 | **Managed-cluster topology loss** — relationship types don't capture worker-node counts, HA controllers, or auto-scaling for managed clusters (EKS, GKE). | 🔴 | Chris/Roberto | Decide new properties vs. separate abstract node types per deployment scenario. |
| I4 | **Abstract-types vs. minimal-types** philosophy — when to introduce a new derived type vs. drive substitution from property values. | 🟡 | Community | Settle case-by-case via worked examples; leaning toward property-based substitution. |
| I15 | **Shared relationship/capability types across abstraction levels** (from `design-guide.md`) — do requirement/capability mapping rules require relationship and capability types to be shared across System/Admin/Device-View profiles? If so, organize them in a shared profile. Related to I1. | 🔵 | Community | Confirm the mapping rules in the spec; decide on a shared profile. |
| I16 | **Component/Port modeling best practices** (from `design-guide.md`) — (a) specify `valid_capability_types` vs. `valid_relationship_types` (or both)? (b) derive new relationship/capability types vs. specialize via `valid_source_node_types`/`valid_target_node_types`? (c) how deep should the type hierarchies go? Related to I4. | 🟡 | Community | **Proposed resolutions drafted in `design-guide.md` (2026-07-15):** declare the constraint in one place (`valid_relationship_types` on the three base capabilities, `valid_capability_types` on relationships); derive a new type only for a clearer name, extra properties/attributes, or extra interface inputs/operations, else specialize via `valid_source_node_types`/`valid_target_node_types`. Ratify 2026-07-22. |
| I17 | **Formalize monitoring & security in the Component/Port pattern** (from `design-guide.md`) — the monitoring pattern was discussed in the TC but never formalized; the security pattern needs work. | 🟡 | Community | **Proposed resolutions drafted in `design-guide.md` (2026-07-15):** monitoring = observability capability on the monitored node + `DependsOn`-based monitoring requirement; security split into perimeter, credentials, and identity/trust (`RegistersWith`) sub-patterns. Ratify 2026-07-22. |
| I21 | **Substituting templates that exercise the abstract profiles** (K5). Note: the existing `microservice` example imports the hand-authored `technology.kubernetes`, which **K6 deletes** — it must be repointed to the kept (auto-generated) Kubernetes profile, or removed. | 🟡 | Chris / Westminster | Repoint/rebuild the Kubernetes substitution example against the auto-generated profile; Prachi's example use case. |
| I22 | **Profile organization / naming** — should the technology profiles live under `community/tosca` or use reverse-DNS (e.g. `io.kubernetes`)? Clarify team-designed profiles vs. broader community contributions. | 🟡 | Chris | Options + trade-offs written up in [`profile-naming.md`](../profiles/community/tosca/docs/profile-naming.md) (2026-07-21), incl. the duplicate Kubernetes copies (`io.kubernetes:3.0` vs `community.tosca.technology.k8s:0.1`) and the `io.kubevirt`/`sh.helm` dependents. Review and decide 2026-07-22. |

## Specification gaps (TOSCA 2.0 → 2.01 errata)

| # | Issue | Status | Owner | Next step |
|---|-------|--------|-------|-----------|
| I5 | **Property refinement in data types** is not properly supported by the spec/processor (the value is overridden rather than augmented). | 🔵 | Calin/TC | Add to the 2.01 errata list. |
| I6 | **Metadata support for TOSCA entities** (operation definitions, notifications, annotations) is missing; currently worked around with properties. | 🔵 | TC | Defer to a future spec version. |
| I7 | **Is an artifact type mandatory** for operation implementations in TOSCA 2.0? Disagreement (Roberto: not required; Chris/Calin: should be). | 🔵 | Calin | Resolve via GitHub discussion / errata. |
| I12 | **Static substitution-mapping limitations** — cannot express dynamic worker-node placement; node filters are the short-term workaround. | 🔵 | TC | Consider a language extension; track against 2.1. |
| I13 | **`type-of-node` / "hash type" function** — a built-in to check a target host's platform type for valid substitutions (cf. Tal's Puccini implementation; also raised in `design-guide.md`). | 🔵 | Chris | Spell out syntax/use cases; propose for the spec. |
| I14 | **Dynamic attachment of implementation artifacts** (from `design-guide.md`) — TOSCA has no construct to attach implementation artifacts (Ansible/Terraform/Bash) to device-view types without deriving new types, risking profile proliferation. | 🔵 | TC | Consider a language construct; track against a future spec version. |
| I23 | **No standard way to describe an operation's execution location** in service templates — TOSCA 2.0 doesn't define where an operation runs. Surfaced (2026-07-15) while discussing artifact-type / implementation refinement in `core`. | 🔵 | TC | Scope the need; consider for errata / a future spec version. |

## Artifacts, functions & portability

| # | Issue | Status | Owner | Next step |
|---|-------|--------|-------|-----------|
| I9 | **Portability of community artifacts** — Python-based implementations aren't portable across orchestrators. Direction: reference implementations + JSON stdin/stdout protocol; separate definitions from implementations (`integrations/`). | 🟡 | Chris/Tal | Document the protocol; build out the integrations directory. |
| I10 | **Input/output handling for Bash (and Python)** — finalize conventions (single JSON env var vs. separate vars; base64 encoding; logging vs. output separation). | 🟡 | Chris/Roberto/Marcel | Converge on the GitHub discussion. |

*I18 (`in_range` signature) was decided at M39 (decision-log **D8**) and is **complete — merged 2026-07-15 (PR #348)**: the 2-arg `(value, [min, max])` signature was applied to **both `in_range` and `in_range_strict`**, with integer/float/string/timestamp/version overloads. Roberto's action item is done, and this **unblocks** the N8 abstract-profile property work.*

## Release & process

| # | Issue | Status | Owner | Next step |
|---|-------|--------|-------|-----------|
| I8 | **Release process.** M39 adopted a simple process (R3/R4); the release workflow is now **done and merged** upstream (packages each `community.tosca.*` profile into a signed CSAR on a `v*` tag). 2026-07-15: `0.1` **scoped to `core` + five `abstract.*`** (technology profiles held — R5), and **held until the new core data types land** (D9). | 🟡 | Chris | Review Roberto's data-types PR (D9), then cut the `0.1`. |
| I11 | **Contribution-load distribution.** The large majority of action items fall to the chair, with Roberto the main second contributor — a throughput and continuity (bus-factor) risk. | 🔴 | Community | Distribute ownership of specific profiles/examples/tooling across contributors. |
| I19 | **Add test information to the governance docs** (Roberto, M39) — reference/describe the community test suite in the governance documentation. | 🔴 | Community | Add a test overview to the governance docs. |

## Upstream OASIS repo — non-test issues

Big-ticket item(s) combed from the OASIS
`oasis-open/tosca-community-contributions` GitHub issue tracker, excluding the
spec test-coverage backlog. Numbers are GitHub issue numbers.

| # | Issue | Status | Owner | Next step |
|---|-------|--------|-------|-----------|
| I20 | **Repo checkout fails on Windows** (OASIS #292) — a path containing a colon (`examples/1.3/.../org.tmforum:1.0`) is invalid on NTFS, so `git clone` fails without `git config core.protectNTFS false`. Blocks all Windows contributors. | 🔴 | Community | Rename the colon-bearing path(s) to be cross-platform; document the naming constraint. |

*Reconciled / already tracked:*
- OASIS **#50** (TOSCA Implementation Landscape) is already tracked in
  [`resources/known-implementations.md`](../resources/known-implementations.md).
- OASIS **#301** ("spec examples use `$in_range`, which does not exist") is the
  same issue as **D8 / I18** — re-adding `in_range` to `community.tosca.core`
  with the TOSCA v1.3 signature addresses it.
- OASIS **#106** ("is `basic-template.yml` a valid service template?") is a
  smaller example-cleanup item (operation inputs as parameter assignments vs.
  property definitions; integer vs. version values) — correct or remove the
  example.

## Collaborations to advance

| # | Item | Status | Notes |
|---|------|--------|-------|
| C1 | **Westminster — Swarmchestrate** (Jay, Prachi): OpenAPI→TOSCA tooling and cloud/edge/fog orchestration. 2026-07-08: now incorporating the **Kubernetes profiles**; Prachi to build a simple example template (Prachi + Jay meet 2026-07-13 on deployment); Prachi raised producing profiles for her own work. | 🟡 | Chris to help with implementation artifacts; see I21. |
| C2 | **Stuttgart — Marcel**: EDMM, Ansible/Terraform translation, infrastructure extraction. | 🟡 | Compare translation approaches. |
| C3 | **Telefonica — Mohamed**: TOSCA adoption in related projects. | 🔵 | Follow up via Jay. |
| C4 | **OPAF / OPAS**, **DMTF Redfish**: control-systems modeling and Redfish→TOSCA generation. | 🟡 | Possible Brazil PoC demo (August). |

---

*Resolved items are recorded in [decision-log.md](decision-log.md).*
