# TOSCA Community — Proposed Agenda (2026-09-09)

**Status:** Draft agenda for 2026-09-09, following 2026-09-02
**Related documents:** [abstract-profile-proposed-changes](../profiles/community/tosca/docs/abstract-profile-proposed-changes.md) · [platform README](../profiles/community/tosca/abstract/platform/README.md) · [design-guide](../profiles/community/tosca/docs/design-guide.md) · [open-issues](open-issues.md) · [decision-log](decision-log.md)

Last week walked the proposed-changes document end to end and agreed five of its eight
proposals — 2.1, 2.3, 2.6, 2.7 and 2.8 — recorded as decisions N9 through N12 and D13.
What is left is narrower and of a different kind: three questions the walk-through
*opened*, one it left unfinished, and the edits themselves.

**The release is now the organizing item.** I8 no longer waits on a design decision; it
waits on the edits, and on three questions that decide what those edits say. Everything
in items 1 to 3 is on the release path. Everything after it is not.

---

## 1. `mgmt-address` — a URL, or a structured type? — 15 min · *I28* · **decision sought**

**This reopens the 2026-06-24 resolution recorded as N7**, and it is the one item that
blocks N8, which in turn blocks the `0.1`.

Section 2.4 gives `ServerPlatform` an `IPv4Socket` and `VirtualizationPlatform` a
string. Roberto's alternative is to type both as the `HttpUrl`-style URL now in `core`,
which validates and stays general.

The open part is whether every management address can honestly be written as a URL.
There is no registered SSH URL scheme, so adopting one means the community publishes its
own convention. Against that, a data type chosen at this level of abstraction cannot be
corrected from below — get it wrong here and no lower layer can fix it.

**Preparation:** the cases to decide against are the six platform types' management
addresses as they are realized today — a server reached over SSH, a cloud API endpoint, a
Kubernetes API server, a Proxmox host. If a URL covers all four honestly, it wins on
validation alone.

**Decision sought:** URL or structured, for each of the two properties.

**Consequence either way:** choosing URL makes `HttpUrl` load-bearing on every
API-addressed platform type, which raises the priority of the second half of I26 —
whether `core`'s data types carry test cases — from housekeeping to a release concern.

## 2. The container-platform credential vocabulary — 10 min · *I29* · **decision sought**

Section 2.4 keys `ContainerPlatform`'s credentials map to `[kubeconfig]`, which is
Kubernetes-specific. A container platform that is Docker with Compose, Docker Swarm or
Nomad authenticates some other way. Agreed on 09-02 to be an oversight in the proposal
rather than a design position, so this is a question of what to add, not whether.

**Decision sought:** the vocabulary. §9.4 means a derived type can only narrow what
`Platform` declares, so a kind left out here cannot be added by a downstream profile
without changing the abstract type again — which is why it has to be right before the
`0.1` freezes it.

## 3. `RelationalDatabase` — derived type or technology value? — 15 min · *I30 / I31 / I4*

`Base` already carries `technology` and `vendor`, so `AtRestData` with
`technology: relational` and `vendor: postgres` expresses the same thing Section 2.5
derives a type for. Roberto asks whether the relational/NoSQL distinction belongs at this
level or is a technology detail; the counter-precedent is `ContainerPlatform` against
`VirtualizationPlatform`, which sit at this level for a distinction of the same kind.

Roberto's own tiebreaker is the usable one: **a derived type earns its place if it has
properties specific to it** — a schema, for instance. Applying it needs the reason the
derived type was introduced, which is being recovered (credential specialization is the
suspicion).

This is the concrete instance of **I4**, the abstract-types against minimal-types
question, and settling it here gives the rule a worked case rather than a principle.

**Also here: I31.** Data and storage have had the least prototyping of any area of the
abstract profiles, and `AtRestData` is the only at-rest type. Stefano's
reverse-engineering work covers storage constructs across providers, and an inventory of
them would tell us how many more of these decisions are coming.

**Decision sought, or an explicit deferral:** Section 2.5 is a candidate to hold out of
the `0.1` rather than freeze it unresolved. Deferring is a legitimate outcome; leaving it
undecided while the tag is cut is not.

## 4. `control-host` — the piece 2.3 did not finish — 15 min · *Questions 6 and 8*

N9 settled the requirement name `host`. It did not settle the second requirement.

`Platform` declares `host` and `links-to` only, so a platform whose control plane deploys
apart from what it controls — Kubevirt, and a multi-node Kubernetes cluster — still
cannot be written down. **The platform README has described this requirement as though it
existed**; it does not, and the README now marks it as proposed.

Two decisions, and the first is small:

- **The name.** `control-host` is the interim spelling, and `runs-on` is unavailable
  because it already means *where this application executes*. Now that `host` is settled
  as the base name, `control-host` reads as its sibling.
- **Question 8 — whether a control node also hosts workloads.** Owned by the
  [platform README](../profiles/community/tosca/abstract/platform/README.md#does-a-control-node-also-host-workloads):
  *set overlap*, where a schedulable control node appears under both `host` and
  `control-host`, against *disjoint sets with a property*. The first states the topology
  honestly but cannot be realized, since a requirement mapping cannot distribute a subset
  of bindings; the second can be built today.

**Decision sought:** the name, and which of the two models the profiles adopt.

## 5. Orchestrated credentials — 10 min · *I27* · **first look**

**Section 5.1**, written up since 09-02. D13 covers a credential the model *references*;
this covers one the orchestrator *creates* — a key pair generated before a VM request, a
certificate issued during deployment, a token minted for a service. A node type per kind
of orchestrated secret, a `Credential` capability on it holding a map of `CredentialRef`,
and a requirement on every node that needs the material.

Raised by Tal on [#281](https://github.com/oasis-open/tosca-community-contributions/discussions/281).
Two pieces are deliberately unresolved and are what the group's input is wanted on:

- **Which profile the `Credential` capability type belongs in.** `core` holds the data
  types, but a capability type is not a data type.
- **Whether the orchestrated-secret node types belong in the abstract profiles at all**,
  or only in the technology profiles that know how to create each kind.

Not a decision item this week. It becomes a Section 2 proposal once those two are
answered.

---

## 6. If time permits

- **Substitution filters against the revised types (I32).** N9 and N11 move the abstract
  types' structure into requirements and capabilities, which is what a substitution
  filter selects on. The filters are being refined and are expected to work, but the
  mechanism has not been walked through with the group.
- **Examples exercising the agreed changes.** Committed on 09-02 for the next couple of
  meetings.
- **I16(c)** — how deep type hierarchies should go. (a) was settled by N9 and (b) by N10;
  (c) is what remains. **I17** — the monitoring and security patterns drafted in
  `design-guide.md` on 07-15 and still unratified after three deferrals.
- **OPAF participation (C4).** Bringing the Open Process Automation Forum's
  control-systems modelling into these meetings, in both directions.
- Carried: Kubernetes profile testing (Prachi, Jay); Tal's OpenAPI→TOSCA generator.

---

**Decisions sought:** the `mgmt-address` type (#1); the container-platform credential
vocabulary (#2); `RelationalDatabase` as a derived type or a technology value, or an
explicit deferral out of the `0.1` (#3); the `control-host` name and the control-node
workload model (#4).

**Everything in #1 to #3 is on the `0.1` path.** After those three, what stands between
the community and its first tag is editing the profiles.
