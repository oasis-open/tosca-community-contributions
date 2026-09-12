# TOSCA Community — Proposed Agenda (2026-09-16)

**Status:** Draft agenda for 2026-09-16, following 2026-09-09
**Related documents:** [abstract-profile-proposed-changes](../profiles/community/tosca/docs/abstract-profile-proposed-changes.md) · [platform README](../profiles/community/tosca/abstract/platform/README.md) · [modeling-methodology](../profiles/community/tosca/docs/modeling-methodology.md) · [credential-orchestration-proposal](../profiles/community/tosca/docs/credential-orchestration-proposal.md) · [artifact-calling-convention-proposal](../profiles/community/tosca/docs/artifact-calling-convention-proposal.md) · [spec-naming-conventions-proposal](../profiles/community/tosca/docs/spec-naming-conventions-proposal.md) · [open-issues](open-issues.md) · [decision-log](decision-log.md)

Last week had two participants. It took the one item that was blocking work — Section 2.9,
now **decision A8**: `core` becomes the standard library and the six base capability and
relationship types move out of it — and deliberately held everything else for a meeting with
fuller attendance rather than settle it thinly. So most of this agenda is last week's, carried
forward intact.

**What is new is what A8 opened.** Two questions came out of that one discussion, and both are
Roberto's. The first has an answer already and needs a decision (item 1). The second needs a
discussion opened before it can have one (item 8).

**September is the deadline the chair set, and three meetings remain in it.** The `0.1` no
longer waits on any design decision — it waits on the edits, and on four questions that decide
what those edits say. Items 1 to 4 are those four. Everything else on this agenda can slip past
the tag without changing it, except I46 in item 5, which amends an edit the tag makes and can
slip only as a breaking change in the next version.

**Items 1 to 10 run to 125 minutes, and the meeting is 60.** The four release-path items take
55 of those, which is the hour once anything else is reached at all. **Item 6 is the one not to
defer again** — its three drafted resolutions have now been carried past five meetings without
being read, and if the hour is short it is better to ratify one of them than to move all three
a sixth time.

---

## Notice — the design guide is now `modeling-methodology.md` — 2 min · **for information**

When the documentation was reorganized on 09-02, the design guide kept the methodology alone —
the Model Continuum, translating between levels, deploying abstract services — and the
Component/Port pattern and the practices built on it moved to
[`design-patterns.md`](../profiles/community/tosca/docs/design-patterns.md). "Design guide" and
"design patterns" then no longer said which of the two to open, so the guide is renamed for what
it holds: [`modeling-methodology.md`](../profiles/community/tosca/docs/modeling-methodology.md),
titled *TOSCA Community Modeling Methodology*. Beyond the title and the opening paragraph, one
section is new: [*Two Vantage Points*](../profiles/community/tosca/docs/modeling-methodology.md#two-vantage-points)
opens the document by saying it is written from the system architect's vantage point rather
than a target-driven one, with *model once, run everywhere* as its aim, and that target-driven
profiles make up the continuum's lower levels. The rest of the content is unchanged.

- **Links inside the repository** are repointed, section anchors included. Where a document
  cited "the design guide" for the naming principle or for data placement, it now points at the
  Component/Port pattern, which is where those have lived since 09-02.
- **Links from outside the repository** to `design-guide.md` stop resolving. Anyone who has
  bookmarked or cited it should update the link; the section anchors are unchanged.

## 1. `relationship_kind` — metadata carries neither inheritance nor obligation — 10 min · *I44* · **decision sought**

**New, out of Roberto's question last week, and on the release path** because it changes what
the base relationship types declare and A8 is about to move them.

The three base relationship types in `core` carry a `relationship_kind` metadata keyname, which
an orchestrator reads to decide how deletion and events propagate. Roberto asked whether a
derived type inherits it. **It does not** — §6.4.2 lists `metadata` among the four common
keynames that do not survive derivation, alongside `derived_from`, `version` and `description`.
And §5.3.1 goes further: metadata *"MAY be ignored by TOSCA Orchestrators and SHOULD NOT affect
runtime behavior."*

**Both consequences are already in the repository**, which is what makes this worth ten minutes
rather than a footnote. `abstract.base` redeclares the keyname on all five of its derived types,
so the rule is understood there — but `InteractsWith` in `abstract.application` derives from
`DependsOn` and declares none, so it has no kind at all; and the vocabulary has drifted in case,
`core` writing `CONTAINMENT` where `abstract.base` writes `containment`. Neither is visible on
an engine that walks the hierarchy for a missing keyname and folds case for a present one, which
is how at least one implementation copes.

**Preparation:** four options are written up in discussion [#363](https://github.com/oasis-open/tosca-community-contributions/discussions/363). Keep redeclaring and fix what is
there; drop the metadata and let derivation carry the kind, since the parent type already names
it; ask for a real `kind` keyname in 2.1 (adjacent to I6); or document it as a convention that
does not travel. **The second interacts with A8** — one set of base types per column means there
is no single triple to walk to — and that interaction is the part worth the group's time.

**Decision sought:** which of the four, and the case convention either way.

## 2. `mgmt-address` — a URL, or a structured type? — 15 min · *I28* · **decision sought**

Carried from 09-09, not reached. **This reopens the 2026-06-24 resolution recorded as N7**, and
it is the one item that blocks N8, which in turn blocks the `0.1`.

Section 2.4 gives `ServerPlatform` an `IPv4Socket` and `VirtualizationPlatform` a string.
Roberto's alternative is to type both as the `HttpUrl`-style URL now in `core`, which validates
and stays general.

The open part is whether every management address can honestly be written as a URL. There is no
registered SSH URL scheme, so adopting one means the community publishes its own convention.
Against that, a data type chosen at this level of abstraction cannot be corrected from below —
get it wrong here and no lower layer can fix it.

**Preparation:** the cases to decide against are the six platform types' management addresses as
they are realized today — a server reached over SSH, a cloud API endpoint, a Kubernetes API
server, a Proxmox host. If a URL covers all four honestly, it wins on validation alone.

**Decision sought:** URL or structured, for each of the two properties.

**Consequence either way:** choosing URL makes `HttpUrl` carry every API-addressed platform type,
which raises the priority of the second half of I26 — whether `core`'s data types carry test
cases — from housekeeping to a release concern.

## 3. The container-platform credential vocabulary — 10 min · *I29* · **decision sought**

Carried from 09-09, not reached. Section 2.4 keys `ContainerPlatform`'s credentials map to
`[kubeconfig]`, which is Kubernetes-specific. A container platform that is Docker with Compose,
Docker Swarm or Nomad authenticates some other way. Agreed on 09-02 to be an oversight in the
proposal rather than a design position, so this is a question of what to add, not whether.

**Decision sought:** the vocabulary. §9.4 means a derived type can only narrow what `Platform`
declares, so a kind left out here cannot be added by a downstream profile without changing the
abstract type again — which is why it has to be right before the `0.1` freezes it.

## 4. `RelationalDatabase` — derived type or technology value? — 20 min · *I30 / I31 / I4 / I45*

Carried from 09-09, not reached. `Base` already carries `technology` and `product`, so
`AtRestData` with `technology: relational` and `product: postgresql` expresses the same thing
Section 2.5 derives a type for. Roberto asks whether the relational/NoSQL distinction belongs at
this level or is a technology detail; the counter-precedent is `ContainerPlatform` against
`VirtualizationPlatform`, which sit at this level for a distinction of the same kind.

Roberto's own tiebreaker is the usable one: **a derived type earns its place if it has properties
specific to it** — a schema, for instance. **Applied, it says this one does not.** Section 2.5
gives `RelationalDatabase` one property, `credential`, and every at-rest store is authenticated to,
so nothing in it is specific to relational data. The downstream profile the type came from
confirms it from the other side:

- the type was introduced without a recorded reason;
- no template sets its `credential`, and no realization reads it;
- its one realization selects on the `technology` property, not on the type.

Nothing depends on the derived type.

This is the concrete instance of **I4**, the abstract-types against minimal-types question, and
settling it here gives the rule a worked case rather than a principle.

**Also here: I31.** Data and storage have had the least prototyping of any area of the abstract
profiles, and `AtRestData` is the only at-rest type. Stefano's reverse-engineering work covers
storage constructs across providers, and an inventory of them would tell us how many more of
these decisions are coming.

**Also here: I45.** `AtRestData` is named on a security axis, *at rest* as against *in transit*
and *in use*, while its five siblings are named for how data is delivered. So the name suggests
the others are not at rest, which is not the distinction the profile draws. What sets the type
apart on the profile's own axis is that data is stored and retrieved on demand; `StoredData` and
`PersistentData` both read alongside `BatchData` and `StreamingData`. TOSCA has no aliasing, so
a rename after the `0.1` is a breaking change: rename now, or keep the name.

**Proposed: withdraw Section 2.5.** A relational database is `AtRestData` with `technology:
relational` and a `product` naming the implementation, until a property specific to relational
data — a schema — gives a derived type something to carry. Holding the section out of the `0.1`
remains the fallback; leaving it undecided while the tag is cut is not.

## 5. `control-host` — the piece 2.3 did not finish — 20 min · *Questions 6 and 8 / I46*

Carried from 09-09, not reached. N9 settled the requirement name `host`. It did not settle the
second requirement.

`Platform` declares `host` and `links-to` only, so a platform whose control plane deploys apart
from what it controls — Kubevirt, and a multi-node Kubernetes cluster — still cannot be written
down. **The platform README has described this requirement as though it existed**; it does not,
and the README now marks it as proposed.

Two decisions, and the first is small:

- **The name.** `control-host` is the interim spelling, and `runs-on` is unavailable because it
  already means *where this application executes*. Now that `host` is settled as the base name,
  `control-host` reads as its sibling.
- **Question 8 — whether a control node also hosts workloads.** Owned by the
  [platform README](../profiles/community/tosca/abstract/platform/README.md#does-a-control-node-also-host-workloads):
  *set overlap*, where a schedulable control node appears under both `host` and `control-host`,
  against *disjoint sets with a property*. The first states the topology honestly but cannot be
  realized, since a requirement mapping cannot distribute a subset of bindings; the second can be
  built today.

**Also here: I46, which amends the same section — a first look.** Section 2.3 keeps three hosting
capabilities, `PlatformHost`, `ExecutionEnvironment` and `DataPlatform`. They share a parent,
declare nothing, and are inherited by every platform, so they neither tell platforms apart nor
let a component ask for a platform that hosts both applications and data. The amendment collapses
them into one capability that `Platform` exposes to every kind of guest, narrowed by derived
platform types through `valid_source_node_types`, and `control-host` then targets that one
capability. Proposal in the amendment to Section 2.3 of
[`abstract-profile-proposed-changes.md`](../profiles/community/tosca/docs/abstract-profile-proposed-changes.md),
reasoning in Problem 8, and generalized as the *One Port, Many Consumers* pattern in
[`design-patterns.md`](../profiles/community/tosca/docs/design-patterns.md#one-port-many-consumers).

**Decision sought:** the name, and which of the two models the profiles adopt. **For I46:** whether
it goes in before the tag, since it changes the N9 edit the `0.1` makes, or after it as a breaking
change.

## 6. The drafted resolutions nobody has ratified — 15 min · *I13 / I16(c) / I17* · **ratification sought**

**Fifth time on an agenda without being read.** Three answers are already written, I16(c)'s and
I17's in [`design-patterns.md`](../profiles/community/tosca/docs/design-patterns.md) and I13's in
[`modeling-methodology.md`](../profiles/community/tosca/docs/modeling-methodology.md), and none
has been ratified, because none has been reached. They are grouped because the work left on each is the same: read
the drafted resolution and say yes or no.

- **I17 — the monitoring and security patterns**, drafted 07-15. Monitoring is an observability
  capability on the monitored node with a `DependsOn`-based monitoring requirement; security
  splits into perimeter, authentication, authorization and identity/trust. **This one pairs with
  item 7**: the credential proposal is a worked realization of the authentication sub-pattern, so
  the pattern can be ratified against working types rather than against prose. I41 is its
  identity/trust half.
- **I16(c) — how deep the type hierarchies should go.** (a) was settled by N9 and (b) by N10 on
  09-02, both indirectly. (c) is what is left of the entry.
- **I13 — the `type-of-node` function**, drafted 08-04, recommending it **not** be added:
  platforms of the same type differing only in what each is designated to become cannot be
  distinguished by type at all, and that case is common, so a property filter covers strictly more
  ground. It carries a follow-on if ratified — the platform-representation list needs a property
  for what a platform is *designated to be*.

I16(c) and I17 were not reached on 07-22 and were dropped from 08-05 to make room; I13 sat in
*if time permits* on 08-05 and 08-12; all three were held on 09-09 for attendance. **That is why
this is item 6 and not a bullet in the carried list.**

**Ratification sought** on each of the three, or an explicit decision to retire the draft.

## 7. Orchestrated credentials — 10 min · *I27* · **first look for the group**

**[Its own document](../profiles/community/tosca/docs/credential-orchestration-proposal.md).**
Walked through on 09-09, but to two people, so this is still the group's first look. D13 covers a
credential the model *references*; this covers one the orchestrator *creates* — a key pair
generated before a VM request, a certificate issued during deployment, a token minted for a
service. A node type per kind of orchestrated secret, a `Credential` capability on it holding a
map of `CredentialRef`, and a requirement on every node that needs the material. The certificate
case is the worked one: common name, alternative names, intended usage and validity on the node
type; the certificate and key produced as file references on the device that created them; the
public information published as attributes for whoever reads it.

Raised by Tal on [#281](https://github.com/oasis-open/tosca-community-contributions/discussions/281).
Two pieces are what the group's input is wanted on:

- **Which profile the `Credential` capability type belongs in.** The chair's answer on 09-09 is
  the **technology base profile** — orchestration happens in the technology column, and the
  material reaches an abstract node by attribute mapping rather than by carrying the capability
  upward. That is a position stated to one other participant, not a decision.
- **Whether the orchestrated-secret node types belong in the abstract profiles at all**, or only
  in the technology profiles that know how to create each kind.

**And a sequencing question — I41.** The proposal models *authentication*, and says trust material
does not belong on the `Credential` port: what a node verifies *others* against is not its own
proof of identity, and publishing both on one port puts two contracts on it. It belongs on a port
of its own — and that port has a worked design in use, a `TrustAnchor` capability publishing what
a node verifies against, `Certification` deriving from it and adding issuance because a leaf
certificate cannot issue, and `AnchorsOn` targeting the anchor while an enrolment relationship
stays on the issuance contract. Together the two are the authentication and identity/trust halves
of I17's security pattern.

The question is when to bring the second one. **Worth a minute at the end of this item**, since
the answer decides whether the group sees one proposal or two.

Not a decision item. It becomes a Section 2 proposal once those two are answered.

## 8. One function, more than one implementation — 10 min · *I43* · **first look**

**New, and Roberto's.** `core` declares eight functions, and all sixteen implementations across
their signatures are typed as the `Python` artifact type. His Puccini-based platform executes custom functions as WebAssembly
plugins under a platform-specific artifact type, so adopting `core` means *editing* `core`. The
profile is portable in its definitions and unportable in its implementations, and there is
currently no way to take one without the other.

**This is the general problem, not a function problem.** An operation implementation may be a Bash
script, a Python module, an Ansible playbook or a Terraform configuration, and which one an
orchestrator can run is the orchestrator's business rather than the profile's. It is the general
form of I9, and the language-extension direction is close to I14.

Two directions were raised on 09-09:

- **A repository convention.** Split the function *definitions* from the implementations, so a
  shared file declares the signatures and each orchestrator supplies its own implementation file
  against them.
- **A 2.1 language extension.** Let one profile carry alternative implementations of the same
  function or operation, with the orchestrator selecting the one it can execute. The chair's
  preference, since it keeps a single profile rather than a family of near-copies.

**Roberto has opened it as discussion [#365](https://github.com/oasis-open/tosca-community-contributions/discussions/365)**, *About actual portability of the core
type profile*. Read it before the meeting, so this item is a read rather than a recap. **Input wanted, not a decision:** whether the answer is a convention we adopt now or a
proposal we take to the TC — and it can be both, in that order.

## 9. The artifact calling convention — one document in — 10 min · *I10* · **first look**

Carried from 09-09, not reached. The specification does not say how an orchestrator passes values
to an implementation artifact, so the contract can only live in the artifact type, which is profile
territory. It does not live there today: `Bash` declares `host`, `Python` declares nothing, and two
orchestrators can both implement `community.tosca.core:Bash` correctly and run the same script to
different effect.

The proposal replaces the per-input environment variable with a single JSON document in one
reserved variable. The four failures it cites all trace to one cause — the environment is a flat
string map the artifact does not own: a boolean spelled two ways depending on whether it arrived
nested, absence arriving as the four characters `null`, inputs colliding silently with the
inherited environment, and an input named `mgmt-address` that cannot be an environment variable at
all. The last of those is a shell's identifier rules setting a naming convention for the profile.

**Two halves, and only one is a recommendation.** The input half proposes the document as a
*default*, with each artifact type declaring its own channel — a variable for Bash because a shell
wants one, `stdin` for Python because a script wants a stream — which is already the practice:
`Ansible` takes a YAML extra-vars file and `Terraform` a `.tfvars.json`. The output half states the
problem and three options without settling it: `stdout` with a sentinel, a file named by a second
variable, or a dedicated descriptor.

**It has picked up a second reason to be here.** A8 settled Section 2.9 except for that section's
proposed deletion of the unused `Bash` artifact type from `core`, which was not reached. `Bash` is
named by no profile in the repository, and the definition that is wanted — one carrying a `host`
property — is already in `community.tosca.technology.base`. But if the calling convention is
declared *by the artifact type* rather than stated in prose, what `core` keeps depends on the
answer here. **It is also adjacent to item 8**: the same medium, the other direction.

**Input wanted, not a decision:** whether the document is the contract and the channel is each
type's own business, which of the three output channels, and whether `Bash` leaves `core`.

## 10. The §1.2.2 naming amendments — submit or withdraw — 5 min · *I39* · **decision sought**

Carried from 09-09, where it was given five minutes and not reached. The one document in the
profiles tree addressed to the OASIS TC rather than to these profiles, drafted and never
submitted. Two amendments to *TOSCA Naming Conventions*: permit snake case for value names
alongside dash case, consistent within a profile, and withdraw the stated rationale that dash case
exists to distinguish value names from keynames; and make the acronym rule context-free, keeping
acronyms upper throughout — `HTTPEndpoint`, `TCPOrUDP`, `TCP`, `DBMS` — rather than respelling an
acronym according to what sits beside it.

Normative impact is none. §1.2.2 already says parsers should not enforce these conventions, so no
document becomes valid or invalid and no existing profile needs editing. CamelCase for entity type
names is explicitly not touched.

It reaches these profiles through D2, which applies the current conventions to them, and the
draft's own count is the argument: the convention on paper is not the one the profiles follow.

**Decision sought:** submit it to the TC against the errata track (P4), or withdraw the draft.
Five minutes is enough for either.

---

## 11. If time permits

- **Substitution filters against the revised types (I32).** N9 and N11 move the abstract types'
  structure into requirements and capabilities, which is what a substitution filter selects on.
  The filters are being refined and are expected to work, but the mechanism has not been walked
  through with the group.
- **Examples exercising the agreed changes.** Committed on 09-02 for the next couple of meetings.
- **OPAF participation (C4).** Bringing the Open Process Automation Forum's control-systems
  modelling into these meetings, in both directions.
- Carried: Kubernetes profile testing (Prachi, Jay); Tal's OpenAPI→TOSCA generator.

---

**Decisions sought:** how a derived relationship type declares its kind (#1); the `mgmt-address`
type (#2); the container-platform credential vocabulary (#3); withdrawing `RelationalDatabase` in
favour of `AtRestData` with `technology` and `product`, or an explicit deferral out of the `0.1`,
and whether to rename `AtRestData` (#4); the `control-host` name, the control-node workload model,
and whether I46's single hosting capability goes in before the tag or after it (#5); and whether the §1.2.2 naming amendments are submitted to
the TC or withdrawn (#10).

**Ratification sought** on the three drafted resolutions in #6, or an explicit decision to retire
each draft.

**Items 7, 8 and 9 want input rather than a decision** — three proposals the group has not
discussed, each becoming a decision item once the questions in it are answered.

**Items 1 to 4 are on the `0.1` path, and September has three meetings left.** After those four,
what stands between the community and its first tag is editing the profiles.

**For information:** the design guide is renamed `modeling-methodology.md` (the notice before
item 1).
