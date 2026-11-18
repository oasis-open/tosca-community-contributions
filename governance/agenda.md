# TOSCA Community — Proposed Agenda (2026-11-18)

**Status:** Draft agenda for 2026-11-18, following 2026-11-11
**Related documents:** [application-types-proposal](../profiles/community/tosca/docs/application-types-proposal.md) · [modeling-methodology](../profiles/community/tosca/docs/modeling-methodology.md) · [container-platform-cluster](../examples/substitutions/container-platform-cluster) · [open-issues](open-issues.md) · [decision-log](decision-log.md)

Four items were held over from 11-11, three of them because removing something from `core` costs
the profiles that already import it. Parts 2 to 4 take those in turn. Part 5 returns to the
application types, carried from 11-11 unchanged.

---

## Part 1 — Since 11-11 — 5 min · **presentation**

- **[#395](https://github.com/oasis-open/tosca-community-contributions/pull/395) is merged**, so
  D17 is done for `Bash` and N25 is in the profile: `ContainerPlatform`'s credentials now accept
  `ca_bundle`. `Python` is the only artifact type left in `core`.
- **I62 is agreed and not yet written**: the `implementation-details` pattern decodes into a node
  template of the substituting template rather than deriving an input from an input.
- **I61 goes to the TC**: I will extend tosca-specs#362 or file a new issue for requirement
  mapping onto a counted template, with the TOSCA Path defects beside it.

---

## Part 2 — Reverting A8 — 15 min · **decision sought** · *I60* · [#391](https://github.com/oasis-open/tosca-community-contributions/discussions/391)

The decision deferred from 11-11. Roberto's case is a template in which only the cluster node is
substituted, where the mapped requirement ends on a node exposing no compatible capability type and
Puccini rejects the template. Mine is that the model continuum substitutes every abstract node, so
the requirement reaches the capability the target's realization maps, and keeping the base types out
of `core` enforces that pattern. Roberto agreed it is good practice and was unsure it should be
enforced. Against that, the types were in `core` originally to encourage the three relationship
kinds across all profiles, which argues for putting them back.

I undertook to report two things: what reverting would mean for my implementation, and whether Tal
and Calin see it differently.

**Decision sought:** revert A8, or keep it and add the server realization the example lacks (I59).

---

## Part 3 — `Python` leaves `core` — 10 min · **decision sought** · *I10, D16, D17*

`core` declares **14 functions and 22 Python implementations across their signatures**:
`to_string`, `to_uppercase`, `to_lowercase`, `random_number`, `validate_json`, `decode_json`,
`validate_yaml`, `decode_yaml`, `ssh_url_to_socket`, `socket_to_ssh_url`, `in_range` and
`in_range_strict` (five signatures each), `now` and `generate_token`.

D16 settled that the implementations leave `core` for the `0.2`, and D17 took `Bash` with them. I
asked on 11-11 to prepare my own profiles first, and having checked, the implementations are not
what I depend on: no template of mine calls any of the fourteen, and my orchestrator implements
`in_range` natively, as a standard validation function. A signature with no implementation already
onboards without complaint, and fails only if something evaluates it, which is the §10.4 behaviour.

**What a consumer loses with them is the `Python` artifact type.** A profile that declares its own
function implementations needs that type declared somewhere, and today it comes from `core`. The
answer is the one this community has already reasoned to: whoever provides the execution environment
declares the artifact type for it. So the type leaves `core` with the implementations, and each
orchestrator's profile declares what it can run. I will add it to mine.

**Decision sought:** remove the `Python` artifact type and the 22 implementations from `core` for
the `0.2`, and say where the implementations go: an `integrations/` profile an orchestrator imports
by choice, or out of the repository.

---

## Part 4 — The credential kinds in dash case — 5 min · **decision sought** · *I64, reopening N23*

N23 kept `ssh_key`, `ssh_password`, `cloud_account`, `x509_cert` and `x509_key` on the ground that
§1.2.2's naming rules cover names rather than the keys and values of a map, and N25 has since added
`ca_bundle`. Roberto's point on 11-11 is that treating map keys like property names is the more
consistent practice, as the `relationship-kind` metadata key already does. I agree with the
principle, and I undertook to say what it costs.

It is the expensive one of today's four. The six kinds appear in **176 files across ten
repositories** of mine, and in three places they are string literals in orchestrator code rather
than profile text, including the list of recognized kinds and two comparisons against `ssh_key`.
Respelling therefore means an engine change, a profile change, every service template and test that
assigns a credential, and a migration path for services already deployed. Worth noting as well that
the lists have already diverged: my orchestrator recognizes a `token` kind that `core` does not
list.

**Decision sought:** respell the credential kinds in dash case, and when — with the `0.2` profile
bump, so consumers absorb it at a version boundary, rather than as a change to `0.2` in flight.

---

## Part 5 — The application types, simplified — 15 min · **decision sought** · *I58, I56* · [proposal](../profiles/community/tosca/docs/application-types-proposal.md)

Carried from 11-11 unchanged. Following N24, the proposal reduces the application profile to one
node type and one capability type:

- **`ServiceApplication`**, deriving from `Application`, an application that provides a service
  across the network. It narrows no requirement, so where it runs is left to its `host` assignment
  and its `technology`.
- **`Endpoint`** with a single optional `url` in place of `port`, `target-port`, `name` and
  `protocol`: the scheme and the port consumers connect to, the host published by the realization,
  and a differing container port in `implementation-details`.
- **`MicroServiceApplication`, `MicroService`, `ServerApplication` and `ServerlessApplication` go**,
  each being a `ServiceApplication` placed on a particular kind of platform.
- **`Application` and `Service` stay** unchanged.

The Online Boutique keeps its `url` form, and the `microservice` substitution example follows.

**Decision sought:** adopt the proposal for the `0.2`, which also settles I56.

---

## Part 6 — The cluster example's structure — 5 min · *I59*

Agreed on 11-11: the abstract service states an implementation detail at the top level by binding
three `ServerPlatform` nodes to the cluster. It should hold one cluster node, and a single
substituting template should create one control node and a counted set of workers from the
platform's `size` (N22), as the revised Online Boutique does. Part 2 decides whether the same change
carries the server realization.

---

## Part 7 — Errata and the TC — 5 min · **for information**

- **Requirement mapping onto counted templates (I61)**, whether a requirement's assignments all go
  to one target or are distributed across the representations of a counted template. The
  specification cannot express what the cluster example does; Roberto would accept extending it with
  that form.
- **The TOSCA Path grammar (#390)**, Roberto's EBNF for the stray commas the §10.3 BNF admits, plus
  a path that names no index meaning all relationships rather than the first, as 2.0 already changed
  an unstated `count_range` to `[0, UNBOUNDED]`.
- **`value` on an incoming parameter (§9.8)**, which I would like the TC to revisit rather than
  work around: an identifier allocated once per service and an operation input fixed by a derived
  type are both reasonable.
- **A TC meeting before the end of the year** to take up errata, published against 2.0 rather than
  issued as a new version, unless the implementation binding proposal, which is new function, makes
  it a 2.1. Roberto, not an OASIS member, is welcome as an observer.

---

## If time permits

- **What a platform is designated to be (I57)**: Part 5 relies on it for selecting a realization.
- **Where examples and substituting templates live (I53)**: Roberto or Stefano to circulate a
  proposal, from 10-07.
- **I44, the relationship kind**: carried until more participants attend. Tal has not been asked.
- **Orchestrated credentials (I27, I41)** and **the artifact calling convention (I10)**.
- **A pinned announcement in Discussions**, deferred on 09-30.

---

**Decisions sought:** A8 reverted or kept with a server realization (Part 2); `Python` and the
implementations out of `core`, and where they go (Part 3); the credential kinds in dash case, and
whether they wait for the `0.2` bump (Part 4); the simplified application types (Part 5).
