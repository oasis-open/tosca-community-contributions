# TOSCA Community — Proposed Agenda (2026-09-09)

**Status:** Draft agenda for 2026-09-09, following 2026-09-02
**Related documents:** [abstract-profile-proposed-changes](../profiles/community/tosca/docs/abstract-profile-proposed-changes.md) · [platform README](../profiles/community/tosca/abstract/platform/README.md) · [design-guide](../profiles/community/tosca/docs/design-guide.md) · [credential-orchestration-proposal](../profiles/community/tosca/docs/credential-orchestration-proposal.md) · [artifact-calling-convention-proposal](../profiles/community/tosca/docs/artifact-calling-convention-proposal.md) · [spec-naming-conventions-proposal](../profiles/community/tosca/docs/spec-naming-conventions-proposal.md) · [open-issues](open-issues.md) · [decision-log](decision-log.md)

Last week walked the proposed-changes document end to end and agreed five of the eight
proposals it then held — 2.1, 2.3, 2.4, 2.6 and 2.7 — with 2.2 already adopted, 2.5 reopened
and 2.8 taken as provisional. The five decisions recorded, D13 and N9 through N12, are a
different five: N10 answers no section of the document, and 2.4 carries no decision of its
own, being the write-up of N8. A ninth proposal has been added since, and leads this agenda.
What is left is narrower and of a different kind: three questions the walk-through
*opened*, one added since, one it left unfinished, and the edits themselves.

**Four proposals have never been discussed at all**, and one of them is on the release
path — Section 2.9, which is why it leads. It and orchestrated credentials (item 2) were
written up after 09-02. The artifact calling convention (item 8) and the §1.2.2 naming
amendments (item 9) were committed the same day as last week's agenda, were not on it, and
the hour went to the proposal document instead. All four are on this agenda for that
reason.

**And three drafted resolutions have never been reached.** I16(c) and I17 were not reached
on 07-22 and were dropped from 08-05 to make room; I13 sat in *if time permits* twice. They
are item 7 this week rather than a bullet in the list they have been dying in.

**The release is now the organizing item.** I8 no longer waits on a design decision; it
waits on the edits, and on four questions that decide what those edits say. Everything
in items 1 and 3 to 5 is on the release path. Item 8 asks whether it joins them. The rest
do not, item 2 included: it is placed second to be reached while the hour is intact, not
because the `0.1` waits on it.

**Items 1 to 9 run to 105 minutes, and the meeting is 60.** The four release-path items —
1, 3, 4 and 5 — take 50 of those, and item 2 takes another 10, so the hour is spent by the
end of item 5. Item 9 is the cheapest at five minutes and ends with a document either
submitted or withdrawn. Item 6 is the one to carry forward — it is the only
release-path-adjacent item that changes nothing the `0.1` freezes. Item 8 is a first look
that loses nothing by waiting a week. **Item 7 is the one not to defer again** — its three
resolutions are written and have been carried past four meetings without being read, and if
the hour is short it is better to take one of them than to move all three a fifth time.

---

## 1. Is `core` the standard library, or also the base of one modelling approach? — 10 min · *I33* · **decision sought**

**Section 2.9, added after this agenda was first drafted, and the one release-path item the
group has not seen** — the three that follow are questions 09-02 opened rather than proposals
in their own right. It leads for that reason, and it is on the release path because it moves
types *between* profiles, and a release freezes where they live.

`core` holds the data types, artifact types and functions any profile can use, and also
the three base capability types and three base relationship types that express one way of
connecting nodes. The proposal moves the six into `abstract.base` and deletes the unused
`Bash`, leaving `core` the standard library the D9 discussion described.

**The argument is that the hierarchy is already split at an arbitrary line.** Every type
derived from the six is in `abstract.base` — `PlatformHost`, `ExecutionEnvironment` and
`DataPlatform` from `Container`; `HostedOn`, `RunsOn` and `AvailableOn` from `ContainedBy`
— so each parent sits one profile below every one of its children with nothing between.
The two base types with no children, `Partner` and `AssociatesWith`, are exactly the two
Section 2.6 gives children to.

**And a consumer depends on the answer.** A profile that imports `core` for its data types
must import it into the default namespace for those types to flow on transitively, and
TOSCA has no selective import — so it takes the six base types as well, and collides with
any of the six it declares itself. `community.tosca.technology.base` is the case already
in the repository: it imports `core`, declares its own artifact, interface and node types,
and uses none of the six.

**Preparation:** the question is whether the six are library content or the vocabulary of
one modelling approach. N13 removed the objection that they must be shared across levels —
capability and requirement mappings impose no type compatibility, so a profile at another
level may define its own.

**Decision sought:** move the six to `abstract.base`, or keep them in `core` and accept
that a consumer takes the vocabulary with the library.

## 2. Orchestrated credentials — 10 min · *I27* · **first look**

**[Its own document](../profiles/community/tosca/docs/credential-orchestration-proposal.md)**,
written up since 09-02, rather than a section of the proposal document — it proposes a
capability type and node types that mostly belong in technology profiles rather than
abstract ones. D13 covers a credential the model *references*; this covers one the
orchestrator *creates* — a key pair generated before a VM request, a certificate issued
during deployment, a token minted for a service. A node type per kind of orchestrated
secret, a `Credential` capability on it holding a map of `CredentialRef`, and a requirement
on every node that needs the material.

Raised by Tal on [#281](https://github.com/oasis-open/tosca-community-contributions/discussions/281).
Two pieces are deliberately unresolved and are what the group's input is wanted on:

- **Which profile the `Credential` capability type belongs in.** `core` holds the data
  types, but a capability type is not a data type.
- **Whether the orchestrated-secret node types belong in the abstract profiles at all**,
  or only in the technology profiles that know how to create each kind.

**And a sequencing question — I41.** The proposal models *authentication*, and says trust
material does not belong on the `Credential` port: what a node verifies *others* against is
not its own proof of identity, and publishing both on one port puts two contracts on it. It
belongs on a port of its own — and that port has a worked design in use, a `TrustAnchor`
capability publishing what a node verifies against, `Certification` deriving from it and
adding issuance because a leaf certificate cannot issue, and `AnchorsOn` targeting the anchor
while an enrolment relationship stays on the issuance contract. Together the two are the
authentication and identity/trust halves of I17's security pattern, which is still
unratified after three deferrals.

The question is when to bring the second one. Proposing it now doubles the credential
discussion; proposing it after this half is agreed means the port pattern it mirrors is
already settled. **Worth a minute at the end of this item**, since the answer decides whether
the group sees one proposal or two.

Not a decision item this week. It becomes a Section 2 proposal once those two are
answered.

## 3. `mgmt-address` — a URL, or a structured type? — 15 min · *I28* · **decision sought**

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

## 4. The container-platform credential vocabulary — 10 min · *I29* · **decision sought**

Section 2.4 keys `ContainerPlatform`'s credentials map to `[kubeconfig]`, which is
Kubernetes-specific. A container platform that is Docker with Compose, Docker Swarm or
Nomad authenticates some other way. Agreed on 09-02 to be an oversight in the proposal
rather than a design position, so this is a question of what to add, not whether.

**Decision sought:** the vocabulary. §9.4 means a derived type can only narrow what
`Platform` declares, so a kind left out here cannot be added by a downstream profile
without changing the abstract type again — which is why it has to be right before the
`0.1` freezes it.

## 5. `RelationalDatabase` — derived type or technology value? — 15 min · *I30 / I31 / I4*

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

## 6. `control-host` — the piece 2.3 did not finish — 15 min · *Questions 6 and 8*

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

## 7. The drafted resolutions nobody has ratified — 15 min · *I13 / I16(c) / I17* · **ratification sought**

Three answers are already written in
[`design-guide.md`](../profiles/community/tosca/docs/design-guide.md) and none has been
ratified, because none has been reached. They are grouped because the work left on each is
the same: read the drafted resolution and say yes or no.

- **I17 — the monitoring and security patterns**, drafted 07-15. Monitoring is an
  observability capability on the monitored node with a `DependsOn`-based monitoring
  requirement; security splits into perimeter, authentication, authorization and
  identity/trust. **This one pairs with item 2**: the credential proposal is a worked
  realization of the authentication sub-pattern, and its scope agrees with the drafted
  pattern independently, so the pattern can be ratified against working types rather than
  against prose. I41, above, is its identity/trust half.
- **I16(c) — how deep the type hierarchies should go.** (a) was settled by N9 and (b) by
  N10 on 09-02, both indirectly. (c) is what is left of the entry.
- **I13 — the `type-of-node` function**, drafted 08-04, recommending it **not** be added:
  platforms of the same type differing only in what each is designated to become cannot be
  distinguished by type at all, and that case is common, so a property filter covers
  strictly more ground. It carries a follow-on if ratified — the platform-representation
  list needs a property for what a platform is *designated to be*.

I16(c) and I17 were not reached on 07-22 and were dropped from the 08-05 agenda to make
room. I13 sat in *if time permits* on 08-05 and 08-12 and was not reached either. **That is
why they are a numbered item this week and not a fourth bullet in the same list.**

**Ratification sought** on each of the three, or an explicit decision to retire the draft.

## 8. The artifact calling convention — one document in — 10 min · *I10* · **first look**

The specification does not say how an orchestrator passes values to an implementation
artifact, so the contract can only live in the artifact type, which is profile territory.
It does not live there today: `Bash` declares `host`, `Python` declares nothing, and two
orchestrators can both implement `community.tosca.core:Bash` correctly and run the same
script to different effect.

The proposal replaces the per-input environment variable with a single JSON document in one
reserved variable. The four failures it cites all trace to one cause — the environment is a
flat string map the artifact does not own: a boolean spelled two ways depending on whether
it arrived nested, absence arriving as the four characters `null`, inputs colliding silently
with the inherited environment, and an input named `mgmt-address` that cannot be an
environment variable at all. The last of those is a shell's identifier rules setting a
naming convention for the profile.

**Two halves, and only one is a recommendation.** The input half proposes the document as a
*default*, with each artifact type declaring its own channel — a variable for Bash because a
shell wants one, `stdin` for Python because a script wants a stream — which is already the
practice: `Ansible` takes a YAML extra-vars file and `Terraform` a `.tfvars.json`, and
neither uses the environment. The output half states the problem and three options without
settling it: `stdout` with a sentinel, a file named by a second variable, or a dedicated
descriptor.

**Why it is here and not in *if time permits*.** `Bash` and `Python` live in `core`, which
the `0.1` freezes, and item 1 proposes deleting `Bash` from it. If the convention is
declared by the artifact type rather than stated in prose, it changes `core` type
definitions.

**Input wanted, not a decision:** whether the document is the contract and the channel is
each type's own business, and which of the three output channels.

## 9. The §1.2.2 naming amendments — submit or withdraw — 5 min · *I39* · **decision sought**

The one document in the profiles tree addressed to the OASIS TC rather than to these
profiles, drafted and never submitted. Two amendments to *TOSCA Naming Conventions*: permit
snake case for value names alongside dash case, consistent within a profile, and withdraw
the stated rationale that dash case exists to distinguish value names from keynames; and
make the acronym rule context-free, keeping acronyms upper throughout — `HTTPEndpoint`,
`TCPOrUDP`, `TCP`, `DBMS` — rather than respelling an acronym according to what sits beside
it.

Normative impact is none. §1.2.2 already says parsers should not enforce these conventions,
so no document becomes valid or invalid and no existing profile needs editing. CamelCase for
entity type names is explicitly not touched.

It reaches these profiles through D2, which applies the current conventions to them, and the
draft's own count is the argument: the convention on paper is not the one the profiles
follow.

**Decision sought:** submit it to the TC against the errata track (P4), or withdraw the
draft. Five minutes is enough for either.

---

## 10. If time permits

- **Substitution filters against the revised types (I32).** N9 and N11 move the abstract
  types' structure into requirements and capabilities, which is what a substitution
  filter selects on. The filters are being refined and are expected to work, but the
  mechanism has not been walked through with the group.
- **Examples exercising the agreed changes.** Committed on 09-02 for the next couple of
  meetings.
- **OPAF participation (C4).** Bringing the Open Process Automation Forum's
  control-systems modelling into these meetings, in both directions.
- Carried: Kubernetes profile testing (Prachi, Jay); Tal's OpenAPI→TOSCA generator.

---

**Decisions sought:** whether the base capability and relationship types move out of
`core` (#1); the `mgmt-address` type (#3); the container-platform credential vocabulary (#4);
`RelationalDatabase` as a derived type or a technology value, or an explicit deferral out of
the `0.1` (#5); the `control-host` name and the control-node workload model (#6); and whether
the §1.2.2 naming amendments are submitted to the TC or withdrawn (#9).

**Ratification sought** on the three drafted resolutions in #7, or an explicit decision to
retire each draft.

**Items 2 and 8 want input rather than a decision** — both are first looks at proposals the
group has not seen, and each becomes a decision item once the questions in it are answered.

**Everything in #1 and #3 to #5 is on the `0.1` path.** After those four, what stands between
the community and its first tag is editing the profiles.
