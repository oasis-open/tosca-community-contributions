# TOSCA Community — Proposed Agenda (2026-11-11)

**Status:** Draft agenda for 2026-11-11, following 2026-10-28 (2026-11-04 was cancelled)
**Related documents:** [application-types-proposal](../profiles/community/tosca/docs/application-types-proposal.md) · [modeling-methodology](../profiles/community/tosca/docs/modeling-methodology.md) · [container-platform-cluster](../examples/substitutions/container-platform-cluster) · [open-issues](open-issues.md) · [decision-log](decision-log.md)

Roberto opened six discussions between 11-02 and 11-06, and I have replied to each. Part 2 takes
them in turn: three question something the community has published, two propose profile changes,
and one is a specification erratum. Part 3 is the application types proposal, simplified to what
we agreed on 10-28.

---

## Part 1 — Since 10-28 — 5 min · **presentation**

- **The 10-28 record**: N24, the application types distinguished by what an application does
  rather than the platform it runs on, and the implementing-file proposal received (I43).
- **Implementing files**: the prototype has not started, and Tal has not yet commented.

---

## Part 2 — Roberto's discussions — 40 min

### 2.1 Reverting A8 · [#391](https://github.com/oasis-open/tosca-community-contributions/discussions/391) · 10 min · **decision sought**

Roberto proposes returning the base capability and relationship types to `core`: a requirement
mapping passes the target node across the boundary, so in the cluster example the agent's
`tech:Container` requirement ends on an abstract server node exposing only abstract capability
types. My reply: the server node is itself substituted, and the methodology's rule that a mapped
requirement must be satisfiable where it ends has the agent reach the capability the server's
realization maps, which must be a `tech:Container`. Shared base types would let the agent
type-check against the abstract node itself. What the check cannot do is run at design time, and
the example shows no server realization.

**Decision sought:** keep A8, and add a server realization to the example (with I59).

### 2.2 Requirement mapping syntax · [#387](https://github.com/oasis-open/tosca-community-contributions/discussions/387) · 10 min · **input wanted**

§15.5 defines a mapping's target as `[node, requirement]`. The cluster example's
`[agent, $relationship_index, host]` is not in the specification, and the specification does not
say what mapping onto a counted node template means. I have said I will correct the example's
README and comments to describe the form as an extension.

**Input wanted:** whether pairing the assignments of one requirement with the representations of a
counted template goes to the TC, beside tosca-specs#362.

### 2.3 Deriving inputs in the `implementation-details` pattern · [#388](https://github.com/oasis-open/tosca-community-contributions/discussions/388) · 10 min · **decision sought**

§9.8 allows `value` only on outgoing parameters, so the methodology's step that defines one input
from another is not conformant. Roberto's alternatives: decode into a property of a node in the
substituting template, accessor functions in `core`, or an `any` type from the TC. I prefer the
first, since the property's data type still validates the decoded value.

**Decision sought:** revise the pattern to decode into a typed node property.

### 2.4 The duplicate `Bash` artifact type · [#389](https://github.com/oasis-open/tosca-community-contributions/discussions/389) · 5 min · **decision sought**

`core` and `technology.base` both declare `Bash`, and `technology.base` imports `core` into its
default namespace, a name conflict under §6.8.4. Roberto prefers removing it from `core`.

**Decision sought:** remove `Bash` and `Python` from `core` together with the function
implementations (D16, I9).

### 2.5 `ca_bundle` for `ContainerPlatform` · [#392](https://github.com/oasis-open/tosca-community-contributions/discussions/392) · 5 min · **decision sought**

A connection by `token` or client certificate to an API server with a private CA needs the CA,
which only a `kubeconfig` carries. A CA bundle authenticates the server rather than the
orchestrator, so either `credentials` is broadened to what the orchestrator connects with, or the
trust anchor gets a property of its own.

**Decision sought:** add `ca_bundle` with a broadened description, or a separate property.

### 2.6 The TOSCA Path grammar · [#390](https://github.com/oasis-open/tosca-community-contributions/discussions/390) · 2 min · **for information**

The §10.3 BNF admits stray commas, and Roberto's EBNF fixes it. A specification erratum, for
Roberto to file against tosca-specs.

---

## Part 3 — The application types, simplified — 15 min · **decision sought** · *I58, I56* · [proposal](../profiles/community/tosca/docs/application-types-proposal.md)

Following N24, the proposal reduces the application profile to one node type and one capability
type:

- **`ServiceApplication`**, deriving from `Application`, an application that provides a service
  across the network. It narrows no requirement, so where it runs is left to its `host`
  assignment and its `technology`.
- **`Endpoint`** with a single optional `url` in place of `port`, `target-port`, `name` and
  `protocol`: the scheme and the port consumers connect to, the host published by the
  realization, and a differing container port in `implementation-details`.
- **`MicroServiceApplication`, `MicroService`, `ServerApplication` and `ServerlessApplication` go**,
  each being a `ServiceApplication` placed on a particular kind of platform.
- **`Application` and `Service` stay** unchanged.

The Online Boutique keeps its `url` form, and the `microservice` substitution example follows.

**Decision sought:** adopt the proposal for the `0.2`, which also settles I56.

---

## If time permits

- **What a platform is designated to be (I57)**: Part 3 relies on it for selecting a realization.
- **Where examples and substituting templates live (I53)**: Roberto or Stefano to circulate a
  proposal, from 10-07.
- **I44, the relationship kind**: carried until more participants attend. Tal has not been asked.
- **Orchestrated credentials (I27, I41)** and **the artifact calling convention (I10)**.
- **A pinned announcement in Discussions**, deferred on 09-30.

---

**Decisions sought (Part 2):** A8 kept (2.1); the `implementation-details` pattern revised (2.3);
`Bash` and `Python` leave `core` (2.4); how a CA bundle is carried (2.5).

**Input wanted (Part 2):** whether requirement mapping onto counted templates goes to the TC (2.2).

**Decision sought (Part 3):** the simplified application types, with `Endpoint`'s `url`.
