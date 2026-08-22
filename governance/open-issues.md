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
| I16 | **Component/Port modeling best practices** (from `design-guide.md`) — (a) specify `valid_capability_types` vs. `valid_relationship_types` (or both)? (b) derive new relationship/capability types vs. specialize via `valid_source_node_types`/`valid_target_node_types`? (c) how deep should the type hierarchies go? Related to I4. | 🟡 | Community | **Proposed resolutions drafted in `design-guide.md` (2026-07-15):** declare the constraint in one place (`valid_relationship_types` on the three base capabilities, `valid_capability_types` on relationships); derive a new type only for a clearer name, extra properties/attributes, or extra interface inputs/operations, else specialize via `valid_source_node_types`/`valid_target_node_types`. **Ratification deferred** — not reached on 2026-07-22, and dropped from the 2026-08-05 agenda to make room. Still to ratify. |
| I17 | **Formalize monitoring & security in the Component/Port pattern** (from `design-guide.md`) — the monitoring pattern was discussed in the TC but never formalized; the security pattern needs work. | 🟡 | Community | **Proposed resolutions drafted in `design-guide.md` (2026-07-15):** monitoring = observability capability on the monitored node + `DependsOn`-based monitoring requirement; security split into perimeter, credentials, and identity/trust (`RegistersWith`) sub-patterns. **Ratification deferred** — not reached on 2026-07-22, and dropped from the 2026-08-05 agenda to make room. Still to ratify. |
| I21 | **Substituting templates that exercise the abstract profiles** (K5). Note: the existing `microservice` example imports the hand-authored `technology.kubernetes`, which **K6 deletes** — it must be repointed to the kept (auto-generated) Kubernetes profile, or removed. | 🟡 | Chris / Westminster | **Example repointed 2026-07-22** (PR #353/#355). Still open on the testing side: Westminster (Prachi, Jay) to exercise `io.kubernetes:1.35` for Swarmchestrate and report back; Chris to follow up 2026-08-05. |
| I24 | **Union types.** The credential work (D11) is one instance of a general gap: TOSCA has no union type, so a value that may take one of several shapes has to be modelled as a type with optional properties, a keyed map, or a set of derived types. The map-plus-`key_schema` approach adopted for credentials is a workaround rather than a language feature. Worth stating as a pattern, and worth knowing whether the TC considers it an errata or a 2.1 item. | 🔴 | Community | Write up the pattern; decide whether to raise it with the TC. |
| I26 | **`HttpUrl` is not anchored at the end** (PR #354, D9). Unlike its siblings `Email` and `Fqdn`, which both end with `$`, the `HttpUrl` regex stops after the host and optional port, so everything after that is unvalidated: `https://example.com garbage here`, a value with a trailing newline and further text, `https://example.com:99999` (port above 65535), and `http://999.999.999.999` (matches the FQDN branch) all validate. Appending `$` alone is **not** the fix — it would reject `https://example.com/path?q=1`, which legitimately passes today; an optional path/query/fragment component is needed before the anchor, or a documented decision that the type validates the authority only. Raises a second question: `core` is now the community's standard library, so its data types arguably need **test cases** to keep the regexes from drifting. **Regex fixed 2026-08-12:** the pattern is now anchored at both ends, the optional port is constrained to 1–65535, and an optional path/query/fragment built from the characters RFC 3986 permits is accepted, so `https://example.com/path?q=1` still passes while trailing text, embedded whitespace and out-of-range ports do not. `$` is kept rather than `\z` for consistency with `Email`/`Fqdn` and for regex-engine portability. | 🟡 | Chris | Regex done. **Still open:** decide whether `core` data types carry test cases. |

## Specification gaps (TOSCA 2.0 → 2.01 errata)

| # | Issue | Status | Owner | Next step |
|---|-------|--------|-------|-----------|
| I5 | **Property refinement in data types** is not properly supported by the spec/processor (the value is overridden rather than augmented). | 🔵 | Calin/TC | Add to the 2.01 errata list. |
| I6 | **Metadata support for TOSCA entities** (operation definitions, notifications, annotations) is missing; currently worked around with properties. | 🔵 | TC | Defer to a future spec version. |
| I7 | **Is an artifact type mandatory** for operation implementations in TOSCA 2.0? Disagreement (Roberto: not required; Chris/Calin: should be). | 🔵 | Calin | Resolve via GitHub discussion / errata. |
| I12 | **Static substitution-mapping limitations** — cannot express dynamic worker-node placement; node filters are the short-term workaround. | 🔵 | TC | Consider a language extension; track against 2.1. |
| I13 | **`type-of-node` / "hash type" function** — a built-in to check a target host's platform type for valid substitutions (cf. Tal's Puccini implementation; also raised in `design-guide.md`). | 🟡 | Chris | **Proposed resolution written up in `design-guide.md` (2026-08-04): do not add the function.** Platforms of the same type differing only in what each is designated to become cannot be distinguished by type at all, and that case is common, so a property filter covers strictly more ground. Carries a follow-on: the platform-representation list needs a property for what a platform is *designated to be*. Not yet ratified. |
| I14 | **Dynamic attachment of implementation artifacts** (from `design-guide.md`) — TOSCA has no construct to attach implementation artifacts (Ansible/Terraform/Bash) to device-view types without deriving new types, risking profile proliferation. | 🔵 | TC | Consider a language construct; track against a future spec version. |
| I23 | **No standard way to describe an operation's execution location** in service templates — TOSCA 2.0 doesn't define where an operation runs. Surfaced (2026-07-15) while discussing artifact-type / implementation refinement in `core`. | 🔵 | TC | Scope the need; consider for errata / a future spec version. |
| I25 | **Monitoring and telemetry escalation.** The *bottom-up* counterpart to top-down refinement: low-level monitoring data summarized and aggregated into high-level system-health attributes. The mechanism already exists — `substitution_mappings.attributes` escalates values from a substituting service onto the substituted node — but there is no written pattern for it. Noted in `design-guide.md` (2026-08-04). | 🔴 | Community | Write the pattern into the design guide. |

## Artifacts, functions & portability

| # | Issue | Status | Owner | Next step |
|---|-------|--------|-------|-----------|
| I9 | **Portability of community artifacts** — Python-based implementations aren't portable across orchestrators. Direction: reference implementations + JSON stdin/stdout protocol; separate definitions from implementations (`integrations/`). | 🟡 | Chris/Tal | Document the protocol; build out the integrations directory. |
| I10 | **Input/output handling for Bash (and Python)** — finalize conventions (single JSON env var vs. separate vars; base64 encoding; logging vs. output separation). | 🟡 | Chris/Roberto/Marcel | Converge on the GitHub discussion. |

*I18 (`in_range` signature) was decided at M39 (decision-log **D8**) and is **complete — merged 2026-07-15 (PR #348)**: the 2-arg `(value, [min, max])` signature was applied to **both `in_range` and `in_range_strict`**, with integer/float/string/timestamp/version overloads. Roberto's action item is done, and this **unblocks** the N8 abstract-profile property work.*

## Release & process

| # | Issue | Status | Owner | Next step |
|---|-------|--------|-------|-----------|
| I8 | **Release process.** M39 adopted a simple process (R3/R4); the release workflow is now **done and merged** upstream (packages each `community.tosca.*` profile into a signed CSAR on a `v*` tag). 2026-07-15: `0.1` **scoped to `core` + five `abstract.*`** (technology profiles held — R5), and **held until the new core data types land** (D9). The D9 dependency cleared 2026-07-22 and the repository still carries no tags. **2026-08-05: `0.1` now waits on the credential model (D11) being in the abstract profiles**, so that the first release carries the settled credential shape rather than one the community would have to revise immediately. D10 likewise settled the `implementation-details` encoding, which `0.1` would otherwise have shipped unreviewed. N8 can ride along, since its credential property follows D11. | 🟡 | Chris | Incorporate D11 into the abstract profiles (with N8), then cut the `0.1` — push the `v0.1` tag, review the draft release, publish. |
| I11 | **Contribution-load distribution.** The large majority of action items fall to the chair, with Roberto the main second contributor — a throughput and continuity (bus-factor) risk. | 🔴 | Community | Distribute ownership of specific profiles/examples/tooling across contributors. |
| I19 | **Add test information to the governance docs** (Roberto, M39) — reference/describe the community test suite in the governance documentation. | 🔴 | Community | Add a test overview to the governance docs. |

## Upstream OASIS repo — non-test issues

Big-ticket item(s) combed from the OASIS
`oasis-open/tosca-community-contributions` GitHub issue tracker, excluding the
spec test-coverage backlog. Numbers are GitHub issue numbers.

Nothing open here today.

*I20 (**repo checkout fails on Windows**, OASIS #292) is **complete — renamed
2026-04-06 (PR #293)**: `examples/1.3/.../org.tmforum:1.0` became
`org.tmforum.1.0`. No tracked path carries a colon, so a Windows `git clone`
no longer needs `core.protectNTFS false`. The naming constraint it raised —
that a profile directory must not use the `name:version` form a profile
identifier does — is still undocumented.*

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
