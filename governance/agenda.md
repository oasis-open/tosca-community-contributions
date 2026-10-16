# TOSCA Community — Proposed Agenda (2026-10-21)

**Status:** Draft agenda for 2026-10-21, following 2026-10-07 (2026-10-14 was cancelled)
**Related documents:** [kubernetes-modeling](../profiles/community/tosca/docs/kubernetes-modeling.md) · [association-proposal](../profiles/community/tosca/docs/association-proposal.md) · [design-patterns](../profiles/community/tosca/docs/design-patterns.md) · [application README](../profiles/community/tosca/abstract/application/README.md) · [open-issues](open-issues.md) · [decision-log](decision-log.md)

The `0.2` is organized around the Online Boutique (R8). Roberto has brought the abstract template
to the revised profiles and, in doing so, questioned what the `Endpoint` capability carries. That
question decides what the abstract template says about every microservice, so it comes first.
Part 3 carries the 10-07 items that were not reached.

---

## Part 1 — Since 10-07 — 5 min · **presentation**

- **The abstract Online Boutique, revised** (Roberto, by email on 10-15): a `cluster` node of type
  `ContainerPlatform` that every microservice is hosted on, `technology` and
  `implementation-details` on every node, and the implementation details taken as inputs.

---

## Part 2 — What the abstract types carry — 20 min · **decision sought**

### 2.1 `Endpoint` carries a Kubernetes Service's properties — 20 min · *I56*

`Application` gives every application a `service` capability of the base type `Service`, and N11
rederived `Endpoint` from it for the network-addressable case. `MicroService` and
`ServerApplication` refine `service` to `Endpoint`, whose `port` and `target-port`, both required,
with `name` and `protocol`, are the fields of a Kubernetes Service port: an exposed port forwarded
to a container port. They come from the first draft of the application profile and were carried
through N11 and N12 unchanged.

**Roberto's question:** the properties are technology-specific, so an abstract profile and an
abstract template are not the place for them; the values could travel in `implementation-details`,
supplied by the user and passed to the substituting template as is. The revised template shows the
point: `frontend` maps port 80 to 8080 and `email` 5000 to 8080, a translation that means nothing
above the Kubernetes realization.

**The same defect reaches `ServerApplication` harder.** Software on a server has no second port to
forward to, so it carries a `target-port` that means nothing, and software that serves nothing,
such as a command-line tool, cannot be typed `ServerApplication` at all. Ubicity found this
rederiving its server-hosted realizations, which stay on the base `Application` until it is
settled.

**Nothing at the abstract level needs the port.** In the interaction pattern of
[`kubernetes-modeling.md`](../profiles/community/tosca/docs/kubernetes-modeling.md#where-application-level-interaction-should-live),
a consuming Pod reads its peer's address and port from the peer's Kubernetes `Service`, reached
through the peer's capability mapping, at the device view.

**Proposed for the `0.2`:** `MicroService` and `ServerApplication` keep the inherited `Service`,
and `Endpoint` is removed; the port values move to each microservice's `implementation-details`;
the abstract Online Boutique follows. This follows N12's reasoning for dropping `processes`, that
what runs on a host is below the System View. Removing the properties breaks any template that
assigns them, which the `0.2` may do, since no compatibility is promised before `1.0`.

**Decision sought:** remove `Endpoint`, or keep it property-free as a marker of the
network-addressable case; and whether the port values belong in `implementation-details`.

---

## Part 3 — Carried from 10-07 — 20 min · **first reading**

### 3.1 What an association may carry · *I54* · [proposal](../profiles/community/tosca/docs/association-proposal.md)

The abstract base profile defines an association as informational, carrying no lifecycle, state
or configuration dependency. That joins two separate questions, whether a relationship orders its
ends and whether it does anything, and leaves no model for two components that configure each
other: two dependencies form a cycle, and an informational association has nowhere to run the
configuration. Proposed: an association orders neither end and may carry operations that run once
both ends exist, never the ordered operations of a dependency. Independent of I44.

### 3.2 One meaning, one type · *I1* · [design-patterns](../profiles/community/tosca/docs/design-patterns.md#best-practices)

Drafted as question 4 under Best Practices: a profile never declares a type that means what an
imported type already means, since nominal typing leaves the two unrelated however alike they
are. Which profile owns each shared type is still open.

### 3.3 Requirement refinement in the specification · [#377](https://github.com/oasis-open/tosca-community-contributions/discussions/377)

§6.4.2 says a refinement need not restate an inherited keyname, but the keyname tables mark
keynames mandatory without saying "unless inherited", and at least one implementation follows the
tables. Tal proposes the tables say "mandatory if not derived". A candidate for the errata track
(P4), with I50 and I51, once spec work resumes.

**Input wanted:** any disagreement, and whether Tal files it.

---

## If time permits

- **Where examples and substituting templates live (I53)**: Roberto or Stefano to circulate a
  proposal, from 10-07.
- **I44, the relationship kind**: carried until more participants attend. Tal has not been asked.
- **Orchestrated credentials (I27, I41)**, **implementations for functions and operations (I43)**,
  **the artifact calling convention (I10)**.
- **A pinned announcement in Discussions**, deferred on 09-30.

---

**Decision sought (Part 2):** what `Endpoint` becomes in the `0.2`, and where the port values go
(2.1).

**Also sought (Part 3):** whether the refinement erratum goes forward (3.3).
