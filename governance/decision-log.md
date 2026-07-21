# TOSCA Community — Decision Log

**Status:** Working log, maintained by the chair
**Related documents:** [README](../profiles/community/tosca/README.md) · [prior-art](../profiles/community/tosca/docs/prior-art.md) · [design-guide](../profiles/community/tosca/docs/design-guide.md) · [abstract-profile-proposed-changes](../profiles/community/tosca/docs/abstract-profile-proposed-changes.md) · [meeting-history](meeting-history.md) · [open-issues](open-issues.md)

Decisions and agreements reached in the weekly TOSCA Community meetings. Older
meetings are referenced by number (**M0** kickoff onward); recent meetings by
**date** (see [meeting-history.md](meeting-history.md)). "Where" points to the
meeting where the decision was made or last confirmed.

---

## Process & logistics

| # | Decision | Where |
|---|----------|-------|
| P1 | Hold weekly meetings (Wednesdays); use Discord for summaries and notifications; collaborate asynchronously via GitHub PRs/issues and Discord. | M0 |
| P2 | After TOSCA v2, prioritize **adoption** (profiles, examples, tooling) over new language functionality. | M5 |
| P3 | Resume the TOSCA TC language meetings (errata / 2.0.1 / 2.1) — initially targeted for January; later a TC meeting targeted for late March / early April. | M13, M24 |
| P4 | Start a **TOSCA 2.0 errata (2.01)** issue list and investigate the OASIS errata process. | M31 |
| P5 | **Move the governance docs to the repository top level** (out of `profiles/community/tosca/governance/`); add test information to the governance docs. | M39 |

## Profile architecture & organization

| # | Decision | Where |
|---|----------|-------|
| A1 | Adopt Roberto's **top-down three-node abstraction** — application / platform / data — as the organizing model; refactor the Online Boutique example to it. | M9–M10 |
| A2 | Structure profiles as a hierarchy: **core** (shared data types), **base** (capability / relationship / node types), and **abstract** domain profiles (application, data, network, platform). | M12, M26 |
| A3 | Separate **profiles** from **examples** in the repository; keep profiles in the profile directory and move examples out. | M9–M10 |
| A4 | Reorganize the profiles directory by **abstraction level** (system-administrator / device / abstract-technology / vendor), retaining "TOSCA" in the directory name. | M25 |
| A5 | Use the **system view / administrative view / device view** as the organizing principle; avoid derivations in very abstract profiles. | M33 |
| A6 | Treat the "model continuum" as a documented **design pattern**, kept at a higher repo level (not a specific implementation). | M11 |

## Node types, properties & relationships

| # | Decision | Where |
|---|----------|-------|
| N1 | Adopt **six abstract data node types** — at-rest, batch, streaming, event, API, cache — distinguished by how data is accessed. | M19 |
| N2 | Add `technology` and `vendor` properties to the base node type to drive substitution (simple strings); later **rename `vendor` → `product`/`implementation`** for generality. | M21, M22 |
| N3 | Add a generic **`name` property** to the base node type (filtering/identification during deployment and debugging). | M21, M31 |
| N4 | Introduce a **"kind" property** on platform node types to drive substitution decisions (KubeVirt / Kubernetes / physical). | M18 |
| N5 | Separate **control plane vs. data plane** in platform nodes; introduce a "control runs on" relationship targeting the execution-environment capability. | M18, M28 |
| N6 | Simplify base relationship types: **remove the root relationship type**; harmonize "hosted on"/"runs on"; keep "interacts with" in the application profile. | M28 |
| N7 | **Credential / mgmt-address properties are specific to each derived platform type** — not harmonized on the base `Platform` type. (Details in the abstract-profile doc.) | M38 |
| N8 | Proceed with a **PR adding platform-specific connection properties** to the abstract platform types — management address, credential file, and config/access file — realizing the M38 platform-specific decision. (Chris) | M39 |

## Data types, artifacts & functions

| # | Decision | Where |
|---|----------|-------|
| D1 | Adopt the **JSON implementation-details + custom-function** convention in the base profile for opaque, substitution-bound data. | M15 |
| D2 | Apply TOSCA **naming conventions**: camelCase for entity types, kebab-case for value names, uppercase acronyms (JSON, YAML, IP, PORT). | M21 |
| D3 | Define **Python and Bash artifact types**; add an optional **entry-point** property for Python (with a default when omitted). | M31, M33 |
| D4 | Input/output value propagation is defined **per-artifact within profiles**, not as a TOSCA-wide standard; lean toward a **single JSON-encoded env var** for complex inputs. | M25, M26 |
| D5 | Standardize on a **single Python module with function names matching TOSCA declarations** and a single positional argument; document a **JSON stdin/stdout protocol**. | M34 |
| D6 | Treat community-provided implementations as **reference implementations**; separate definitions from implementations and provide per-orchestrator examples (an `integrations/` directory). | M34 |
| D7 | Use a **simple file-reference credential data type** (a map of name + file/reference) rather than embedding secrets. | M22 |
| D8 | Re-add `in_range` to `community.tosca.core` (removed as a built-in in TOSCA 2.0) using the **TOSCA v1.3 2-arg `(value, [min, max])` signature** (not the 3-arg `value, min, max` form), to ease v1.3→v2.0 template upgrades; ensure consistency with other function implementations (addresses OASIS #301). **Done — merged 2026-07-15 (PR #348, Roberto)**: the same 2-arg signature was applied to **both `in_range` and `in_range_strict`** (open interval `min < value < max`), with overloads for integer / float / string / timestamp / version. | M39; merged 2026-07-15 |
| D9 | Add a **standard-library set of core data types** to `community.tosca.core` — email address, URL, FQDN, IPv4 (with constraints) — for consistent data-type descriptions across profiles. (Roberto to PR.) | 2026-07-15 |

## Modeling approach (Kubernetes / examples)

| # | Decision | Where |
|---|----------|-------|
| K1 | Use the **Online Boutique** microservices app as the primary worked example; add others (e.g. VetStar Bench) later. | M1, M5 |
| K2 | Explore **both** substitution-mapping and capability-type approaches via different examples before committing — Chris on substitution mapping, Tal on capability types. | M4–M8 |
| K3 | For dynamic worker-node placement, use **label-based node filters** short-term; consider a language extension long-term. | M12, M13 |
| K4 | Defer auto-scaling/HA modeling for managed clusters; prioritize a "number of worker nodes" property and a generic subnet model. | M29 |
| K5 | **Validate the abstract profiles by building substituting templates that exercise them**, starting with the (auto-generated) **Kubernetes** profile; Westminster (Prachi/Jay) to contribute example templates. | 2026-07-08 |
| K6 | **Kubernetes profiles — keep the auto-generated, delete the manual.** The auto-generated Kubernetes profile (from the OpenAPI) is more complete than the earlier hand-authored `community.tosca.technology.kubernetes`; delete the manual one and keep the generated one, **relocating the manual profile's README content** into the community repo. (Tal is building a similar auto-generation via a different method; keep room for multiple modeling approaches.) | 2026-07-15 |

## Release & versioning

| # | Decision | Where |
|---|----------|-------|
| R1 | Keep the community profiles at **version `0.1`** for now; **freeze `0.1`** once stable, then plan future versions. | M38 |
| R2 | Begin planning **version tracking and a formal release process** that publishes immutable release artifacts (building CSAR files raised as a candidate mechanism). | M38 |
| R3 | Adopt a **simple release process**: a GitHub workflow that packages profiles as **CSAR release artifacts**, starting with a **`0.1`** release once current changes land. **Keep the flat directory structure** — version-specific subdirectories were considered and rejected. | M39 |
| R4 | **Set up the community release workflow by adapting an existing, proven CSAR-build + signing workflow** rather than authoring one from scratch. Target a **stable `0.1` of the core profile by ~2026-07-15**. | 2026-07-08 |
| R5 | **`0.1` ships `core` + the five `abstract.*` profiles (six TOSCA files).** The technology-specific profiles are held back — not yet mature enough for release. Cutting `0.1` also waits on the new core data types (D9). | 2026-07-15 |

---

*Items still under discussion are tracked in [open-issues.md](open-issues.md).*
