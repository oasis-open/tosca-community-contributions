# Profile Organization and Naming

**Status:** Discussion draft (2026-07-21), for review at the 2026-07-22 TOSCA
Community meeting — issue I22
**Audience:** TOSCA Community
**Purpose:** Decide when profiles should use the `community.tosca.*` namespace
versus reverse-DNS names (e.g. `io.kubernetes`), and clarify the boundary between
team-designed profiles and broader community contributions.

**Related documents:** [README](../README.md) · [prior-art](prior-art.md) · [design-guide](design-guide.md#profile-organization) · [abstract-profile-proposed-changes](abstract-profile-proposed-changes.md) · [meeting-history](../../../../governance/meeting-history.md) · [decision-log](../../../../governance/decision-log.md) · [open-issues](../../../../governance/open-issues.md)

---

The repository currently mixes two naming conventions for profiles. This
document lays out the choice and its trade-offs so the community can settle when
each applies.

## The concrete case that forces the question

The auto-generated Kubernetes **resource** profile lives in the repository
**twice, under two different names**, from the same generated source:

| Path | Advertised profile name | Scheme |
|---|---|---|
| `profiles/io/kubernetes/3.0` | `io.kubernetes:3.0` | reverse-DNS |
| `profiles/community/tosca/technology/k8s` | `community.tosca.technology.k8s:0.1` | `community.tosca.*` |

More broadly, the repo carries a `community.tosca.*` hierarchy (`core`,
`abstract.*`, `technology.base` / `technology.k8s`) alongside reverse-DNS
profiles (`io.kubernetes`, `io.kubevirt`, `sh.helm`).

**Two reasons this needs a decision, not just a preference:**

1. **Nominal typing makes the duplicate a hazard.** Two profiles with identical
   content but different names define *distinct, incompatible* types. A template
   importing `io.kubernetes:3.0` gets different types than one importing
   `community.tosca.technology.k8s:0.1` — they will not interoperate. The
   duplicate should collapse to a single name.
2. **A name already has dependents.** `profiles/io/kubevirt/2.5` and
   `profiles/sh/helm/3.0` both import `io.kubernetes:3.0`. Whichever name we drop,
   its importers must be repointed.

## Option A — `community.tosca.*` for everything

**For:**
- One coherent namespace signals a single, curated, community-maintained set;
  clear stewardship boundary.
- Consistent with the existing `core` and `abstract.*` layer, and easy to scope a
  release around ("the `community.tosca.*` profiles").
- Avoids implying an *official* or *singular* claim over a technology's own
  namespace (`io.kubernetes` can read as "the" Kubernetes profile).

**Against:**
- Verbose and deeply nested (`community.tosca.technology.k8s`).
- Reverse-DNS is the more established convention for technology/vendor profiles
  in the broader TOSCA and software ecosystem.
- For profiles generated from a standard, `community.tosca.*` hides the origin —
  the Kubernetes OpenAPI's own API groups (`io.k8s.api.*`) map naturally to
  reverse-DNS, not to `community.tosca.technology.*`.
- Outside contributors typically name profiles reverse-DNS; forcing everything
  into `community.tosca.*` adds friction and makes contributed profiles feel
  second-class.

## Option B — reverse-DNS for everything (`io.kubernetes`, `sh.helm`, …)

**For:**
- The established, familiar convention (mirrors Java-style package naming and
  TOSCA prior art); self-describing origin.
- Natural for generated profiles that track an upstream API's own namespace.
- Uniform with community-contributed profiles, which will use reverse-DNS anyway.
- Shorter and flatter.

**Against:**
- Ambiguous authority: `io.kubernetes` implies a single/official Kubernetes
  profile, when it's one community rendering and other renderings may coexist
  (e.g. a different generation method).
- No visible boundary between curated, team-designed profiles and drive-by
  contributions — everything looks equally authoritative.
- Effectively claims namespaces (`io.kubernetes`, `sh.helm`) the community does
  not control.
- Version semantics collide: `io.kubernetes:3.0` (tracking an API/tool version)
  reads differently from a `0.1` community release line.
- Harder to say "these N profiles are the community's designed, released set."

## Option C — hybrid (a documented split)

`community.tosca.*` for the **team-designed, opinionated layer** (`core`,
`abstract.*`, and any hand-designed technology models); **reverse-DNS** for
**technology / vendor / generated / contributed** profiles.

**For:**
- Plays to each scheme's strength: the namespace signals stewardship for the
  designed layer; reverse-DNS fits technology and contributed profiles.
- Matches what the repo already looks like in practice.

**Against:**
- Two conventions in one repo can confuse newcomers; needs a **clear, written,
  enforced rule** for which goes where.
- The boundary ("opinionated/team-designed" vs. "technology/contributed") can be
  fuzzy in edge cases and will need judgment calls.

## Proposed direction (to react to, not a foregone conclusion)

Adopt **Option C** with an explicit rule: *team-designed, opinionated profiles →
`community.tosca.*`; technology/vendor/generated/contributed profiles →
reverse-DNS.* Independently of the rule, **collapse the duplicate Kubernetes
resource profile to one name** and repoint `io.kubevirt` and `sh.helm`.

## Questions for the group

1. Which convention — A, B, or C?
2. If C, where exactly is the line, and where does the generated Kubernetes
   resource profile fall?
3. For the duplicate: which of the two names do we keep, and who owns the
   repoint of the dependents?
