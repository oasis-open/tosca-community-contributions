# TOSCA Community — Proposed Agenda (2026-09-16)

**Status:** Draft agenda for 2026-09-16, following 2026-09-09
**Related documents:** [abstract-profile-proposed-changes](../profiles/community/tosca/docs/abstract-profile-proposed-changes.md) · [modeling-methodology](../profiles/community/tosca/docs/modeling-methodology.md) · [design-patterns](../profiles/community/tosca/docs/design-patterns.md) · [credential-orchestration-proposal](../profiles/community/tosca/docs/credential-orchestration-proposal.md) · [artifact-calling-convention-proposal](../profiles/community/tosca/docs/artifact-calling-convention-proposal.md) · [spec-naming-conventions-proposal](../profiles/community/tosca/docs/spec-naming-conventions-proposal.md) · [open-issues](open-issues.md) · [decision-log](decision-log.md)

The meeting has three parts. **First, what changed since 09-09**, presented rather than
discussed: a great deal moved in a week, most of it into the profiles, and the group cannot
decide against changes it has not seen. **Second, the decisions the `0.1` still waits on**, in
the order the release needs them. **Third, the outstanding proposals**: what each one is, where
it stands, and what it needs next.

**September is the deadline the chair set, and after today two meetings remain in it.**
Everything agreed so far is written into the profiles except two edits, N8 and N9. The six
questions in Part 2 decide what those two edits say and what the already-written types keep.
Nothing in Part 3 changes the `0.1`. TOSCA has no aliasing, so any Part 2 question left until
after the tag comes back as a breaking change in the next version.

**The three parts fill the hour, and Part 2 is the one to protect.** If the presentation runs
long, Part 3 gives way. Each of its items links the document to read beforehand, so a proposal
not reached loses a week, not its preparation.

---

## Part 1 — What changed since 09-09 — 15 min · **presentation**

### Written into the profiles — [#369](https://github.com/oasis-open/tosca-community-contributions/pull/369), 09-12

Five agreed decisions are now in the YAML, and one proposal is withdrawn. Each is marked in the
[decision log](decision-log.md).

- **A8 — `core` is the standard library.** The six base capability and relationship types are in
  `abstract.base`, with a copy in `technology.base`, and `core` holds data types, artifact types
  and functions. `Bash` stays in `core` until Part 2 settles it.
- **D13 — `CredentialRef` and `NamedCredentialRef` are in `core`.** The vocabulary each platform
  type accepts arrives with N8.
- **N11 — one interaction port on `Application`.** Every application exposes `service` and
  reaches another's through `interacts-with`, and `Endpoint` derives from `Service`. Both examples
  in the repository use the new names.
- **N12, in part — `ServerApplication`**, without `processes`. Its placement requirement becomes
  `host` with N9.
- **N15 — `Network` carries `cidr_block` and `internet_accessible`.** Agreed on 09-02 and
  recorded as a decision. It stays provisional pending the `technology`-based network model I2
  describes.
- **N14 — `RelationalDatabase` is withdrawn.** A relational database is `AtRestData` with
  `technology: relational` and a `product`. The proposed `RelationalDatabase` carried nothing of
  its own: no template set its one property, and its one realization selected on `technology`,
  not on the type.

**Still to be written:** N8, the platform connection properties, once Part 2 settles I28 and
I29; and N9 with the rest of N12, once Part 2 says whether I46 goes in first.

### Proposals drafted for today — [#367](https://github.com/oasis-open/tosca-community-contributions/pull/367), 09-12

- **I28 — `mgmt-address` as a URL.** Section 2.4 now carries the findings, and a proposal for
  what `core` would add. Part 2.1.
- **I46 — one hosting capability instead of three**, as an amendment to Section 2.3, generalized
  as the [*One Port, Many Consumers*](../profiles/community/tosca/docs/design-patterns.md#one-port-many-consumers)
  pattern. Part 2.2.
- **I29 — the container-platform credential vocabulary**, widened from `[kubeconfig]` to four
  kinds. Part 2.4.

### Documentation

- **The design guide is now [`modeling-methodology.md`](../profiles/community/tosca/docs/modeling-methodology.md)**,
  titled *TOSCA Community Modeling Methodology*. The Component/Port pattern moved to
  `design-patterns.md` on 09-02, and "design guide" no longer said which of the two to open. One
  section is new, [*Two Vantage Points*](../profiles/community/tosca/docs/modeling-methodology.md#two-vantage-points):
  the document is written from the system architect's vantage point, with *model once, run
  everywhere* as its aim, and target-driven profiles make up the continuum's lower levels. Links
  inside the repository are repointed. **Links to `design-guide.md` from outside the repository
  stop resolving**; the section anchors are unchanged.
- **The proposal document now holds only what is still open**: Sections 2.3 and 2.4, and the part
  of 2.7 that waits on 2.3. The implemented sections have left it, their decisions to the decision
  log, their types to the profile READMEs, and the one general argument among them, on where
  application ends and data begins, to the modeling methodology. The one open
  question found in them, whether `Processes` should tell reading from writing, is now I48.

### New issues

- **I45** — `AtRestData` is named on a security axis, where its siblings are named for how data
  is delivered. Part 2.5.
- **I46** — one hosting capability. Part 2.2.
- **I47** — §8.2.1, read literally, lets a derived node type *widen* a capability's
  `valid_source_node_types`, contradicting §5.1.3, §8.1 and §8.4.1. I46 relies on the narrowing
  reading. Filed as erratum [oasis-tcs/tosca-specs#371](https://github.com/oasis-tcs/tosca-specs/issues/371).

### Discussions

- **[#363](https://github.com/oasis-open/tosca-community-contributions/discussions/363) — how a
  derived relationship type declares its kind (I44)**, posted after 09-09 with four options.
  Roberto has replied with a preference and a fifth option. Part 2.3.
- **[#365](https://github.com/oasis-open/tosca-community-contributions/discussions/365) — the
  portability of `core` (I43)**, opened by Roberto on 09-10 with three approaches of his own.
  Part 3.3.

### Specification errata (P4)

Eight errata have been filed against TOSCA 2.0 since 09-09. Three bear on decisions this group
has taken:

- [#369](https://github.com/oasis-tcs/tosca-specs/issues/369) — §15.2–15.5 require type
  compatibility for property and attribute mappings and say nothing about capability and
  requirement mappings. N13 rests on the reading that none is required there.
- [#371](https://github.com/oasis-tcs/tosca-specs/issues/371) — I47, above.
- [#368](https://github.com/oasis-tcs/tosca-specs/issues/368) and
  [#370](https://github.com/oasis-tcs/tosca-specs/issues/370) — §15.5.4's rules for a mapping onto
  a selectable node, and rule 2 reading a type that a `substitution_filter` can narrow.

The other four, [#372](https://github.com/oasis-tcs/tosca-specs/issues/372) to
[#375](https://github.com/oasis-tcs/tosca-specs/issues/375), concern implementation definitions,
workflow outputs, and how `$and`, `$or` and `$equal` treat an unassigned value.

---

## Part 2 — The decisions the `0.1` still waits on — 30 min · **decisions sought**

In the order the release needs them: I28 decides N8, `control-host` and I46 decide N9, and the
other four decide what the already-written types keep.

### 2.1 `mgmt-address` — a URL, or a structured type? — 8 min · *I28*

This reopens the 2026-06-24 resolution recorded as N7, and it is what N8 waits on.

**The proposal ([Section 2.4](../profiles/community/tosca/docs/abstract-profile-proposed-changes.md)).**
Declare `mgmt-address` once on `Platform`, beside `credentials`, typed as a URL, and let each
platform type narrow the schemes the way it narrows the credential kinds: `ServerPlatform`
refines it to `SshUrl`, `VirtualizationPlatform` to `HttpUrl`, and `ContainerPlatform` keeps
`Url` with a validation admitting `https`, `tcp` and `unix`. `core` gains three things:

- **a `Url` type** validating RFC 3986's generic syntax, from which `HttpUrl` derives;
- **`SshUrl`**, for `ssh://host[:port]`. IANA holds a provisional `ssh` registration from an
  expired IETF draft, and OpenSSH, Git and Docker agree on this subset, so the community cites a
  convention rather than publishing one. It carries no user, since the login is the credential's
  `name`, and no fingerprint, since a host-key fingerprint is trust material (I41);
- **two functions**, one reading a URL's parts and one composing a URL. The built-ins cannot read
  a port that may be absent or a bracketed IPv6 host.

**The cost** is that a URL has to be parsed to be read in parts, where a socket yields its host
by path. The proposal pays it once per realization, in the substituting template's inputs and
outputs, and nothing below the boundary changes.

**Precondition:** the other platform types' addresses (`PaasPlatform`, `SaasPlatform`,
`ServerlessPlatform`) have to be listed first, since a derived type can narrow `Url` but cannot
leave it.

**Decision sought:** take the URL route, which puts `Url`, `SshUrl` and the two functions into
`core` for the `0.1`, with test cases per I26; or keep per-type structured types. If the URL
route, the two functions need names.

### 2.2 The control plane, and one hosting capability — 8 min · *Questions 6 and 8 / I46*

N9 settled the requirement name `host`. It did not settle the second requirement a platform
needs when its control plane deploys apart from what it controls, as Kubevirt and a multi-node
Kubernetes cluster do. The platform README marks that requirement as proposed.

- **The name.** `control-host` reads as `host`'s sibling. `runs-on` is unavailable, since it
  already means where an application executes.
- **Question 8 — whether a control node also hosts workloads**
  ([platform README](../profiles/community/tosca/abstract/platform/README.md#does-a-control-node-also-host-workloads)).
  *Set overlap* states the topology honestly but cannot be realized, since a requirement mapping
  cannot distribute a subset of bindings. *Disjoint sets with a property* can be built today.
- **I46 — one hosting capability instead of three.** `PlatformHost`, `ExecutionEnvironment` and
  `DataPlatform` share a parent, declare nothing, and are inherited by every platform, so they
  neither tell platforms apart nor let a component ask for a platform that hosts both applications
  and data. The amendment to Section 2.3 collapses them into one capability that `Platform`
  exposes to every kind of guest, which derived platform types narrow through
  `valid_source_node_types`. `control-host` then targets it too. It relies on the narrowing reading
  of §8.2.1 (I47).

**Decisions sought:** the name; which workload model the profiles adopt; and whether I46 goes in
before the tag, since it changes the N9 edit the `0.1` makes. If it does, the single type needs a
name.

### 2.3 How a derived relationship type declares its kind — 6 min · *I44* · [#363](https://github.com/oasis-open/tosca-community-contributions/discussions/363)

The base relationship types carry `metadata: {relationship_kind: …}`, which an orchestrator reads
to decide how deletion and events propagate. §6.4.2 excludes `metadata` from derivation, and
§5.3.1 says metadata may be ignored and should not affect runtime behavior. `abstract.base`
redeclares the keyname on all six derived types, but in lower case where the base types write
upper case, and the profile now carries a comment noting the difference.

Five options:

1. **Redeclare** on every derived type, with one case convention.
2. **Drop the metadata** and let derivation carry the kind. After A8 that means one set of base
   types per column for a consumer to recognize.
3. **A `kind` keyname** on relationship types, asked for in 2.1.
4. **Document it** as a convention that does not travel.
5. **New, Roberto's: extend `directives`.** Requirement assignments already take `directives`,
   admitting `internal` and `external`. Adding `containment`, `dependency` and `association` moves
   the kind from the relationship type to the node template, and base relationship types split
   by kind would no longer be needed.

Roberto prefers 3, with 1 in the meantime. Options 3 and 5 are language changes, so what the
`0.1` ships is 1, 2 or 4.

**Decision sought:** which of those the `0.1` ships, and the case convention; and whether 3 or 5
goes to the TC.

### 2.4 The container-platform credential vocabulary — 3 min · *I29*

**Proposed resolution ([Section 2.4](../profiles/community/tosca/docs/abstract-profile-proposed-changes.md)):**
`[kubeconfig, token, x509_cert, x509_key]`, the kinds following from what each connection opens.

- `kubeconfig` for every Kubernetes distribution.
- `token` for Nomad's ACL token, or a Kubernetes bearer token held without a kubeconfig.
- `x509_cert` and `x509_key` for a remote Docker daemon over mutual TLS (and so Compose and a
  Swarm manager, which speak its API), and for Nomad with mutual TLS.

The SSH kinds stay on the `ServerPlatform` hosting the platform, since an SSH login opens the
host, and `cloud_account` stays on `VirtualizationPlatform`. The draft argues that widening a
`key_schema` breaks nothing downstream, so this can follow the `0.1` rather than hold it.

**Decision sought:** confirm the vocabulary, and whether it goes into the `0.1` or after it.

### 2.5 `AtRestData`'s name — 3 min · *I45*

"At rest" is a security term, set against data in transit and in use. The data profile's other
five types are named for how data is delivered, so the name suggests its siblings are not at
rest, which is not the distinction the profile draws. What sets the type apart on the profile's
own axis is that data is stored and retrieved on demand. `StoredData` and `PersistentData` both
read alongside `BatchData`, `StreamingData` and `EventData`.

**Decision sought:** rename before the `0.1`, or keep the name. After the tag a rename is a
breaking change.

### 2.6 Does `Bash` leave `core`? — 2 min · *I10*

The one part of the `core` proposal that A8 did not settle. No profile in the repository names `core`'s
`Bash`, and `technology.base` declares the `Bash` that is wanted, carrying `host`. The case for
waiting: if the calling convention (3.4) is declared by the artifact type, what `core` keeps
depends on it.

**Decision sought:** delete `core`'s `Bash` for the `0.1`, or keep it until the calling
convention is settled.

---

## Part 3 — Outstanding proposals — 15 min · **status, and what each needs**

Five proposals have not had the group's attention, three of them drafted resolutions waiting only
for a yes or a no. This part does not work through them. For each, it says what the proposal is
and asks what it needs next: a full slot, a written review, ratification, or retirement.

### 3.1 Three drafted resolutions awaiting ratification · *I13 / I16(c) / I17*

Carried past five meetings without being read. **If only one item in Part 3 is reached, it
should be this one**: each needs a yes or a no, not a discussion.

- **I17 — the monitoring and security patterns**
  ([`design-patterns.md`](../profiles/community/tosca/docs/design-patterns.md)), drafted 07-15.
  Monitoring is an observability capability on the monitored node with a `DependsOn`-based
  requirement; security splits into perimeter, authentication, authorization and identity/trust.
  It pairs with 3.2, a worked realization of its authentication half.
- **I16(c) — how deep the type hierarchies should go**
  ([`design-patterns.md`](../profiles/community/tosca/docs/design-patterns.md)). Parts (a) and (b)
  were settled by N9 and N10.
- **I13 — no `type-of-node` function**
  ([`modeling-methodology.md`](../profiles/community/tosca/docs/modeling-methodology.md)), drafted
  08-04. Platforms of one type that differ only in what each is designated to become cannot be
  told apart by type, so a property filter covers strictly more ground. If ratified, the
  platform-representation list needs a property for what a platform is designated to be.

### 3.2 Orchestrated credentials · *I27 / I41* · [proposal](../profiles/community/tosca/docs/credential-orchestration-proposal.md)

D13 covers a credential the model *references*; this covers one the orchestrator *creates*. A
node type per kind of orchestrated secret, a `Credential` capability on it holding a map of
`CredentialRef`, and a requirement on every node that needs the material, with a certificate as
the worked example. Two questions are open: which profile the `Credential` capability belongs in
(the chair's position is the technology base profile), and whether the orchestrated-secret node
types belong in the abstract profiles at all. **I41** asks whether the identity and trust port
(`TrustAnchor`, `Certification`, `AnchorsOn`) comes with this proposal or after it. I29's
certificate kinds need that trust anchor too.

### 3.3 One function, more than one implementation · *I43* · [#365](https://github.com/oasis-open/tosca-community-contributions/discussions/365)

`core`'s eight functions carry sixteen implementations, all typed `Python`, so a platform that runs
custom functions as WebAssembly plugins has to edit `core` to use it. Roberto's discussion sets out
three approaches:

- **Split `core`** into portable definitions and orchestrator-specific files, with the consumer
  importing the one for its orchestrator.
- **Ship no implementations** in the community profiles, and have each orchestrator publish an
  implementation profile for each community release, refining the function definitions (§10.4).
- **Conditional inclusion**, a 2.1 extension marking parts of a file for one orchestrator or
  another.

The 09-09 meeting raised a fourth: one profile carrying alternative implementations, with the
orchestrator selecting the one it can run. Roberto notes he has not yet tried any of them. The
same question reaches operation implementations (I9, I14).

**Input wanted:** which approach to prototype first.

### 3.4 The artifact calling convention · *I10* · [proposal](../profiles/community/tosca/docs/artifact-calling-convention-proposal.md)

The specification does not say how an orchestrator passes values to an implementation artifact,
so the contract belongs in the artifact type. The proposal replaces a variable per input with
one JSON document, each artifact type declaring its own channel: a variable for Bash, `stdin`
for Python. The output channel is left open among three options. Adjacent to 3.3, the same medium
in the other direction, and to 2.6.

### 3.5 The §1.2.2 naming amendments · *I39* · [proposal](../profiles/community/tosca/docs/spec-naming-conventions-proposal.md)

Drafted for the TC and never submitted: permit snake case for value names, and keep acronyms
upper case throughout. No normative impact, since §1.2.2 already says parsers should not enforce
the conventions. **Decision sought, and five minutes is enough:** submit it on the errata track
(P4), or withdraw it.

---

## If time permits

- **Substitution filters against the revised types (I32).** N9 and N11 move the abstract types'
  structure into requirements and capabilities, which is what a substitution filter selects on.
  The mechanism has not been walked through with the group.
- **Examples exercising the agreed changes.** The two in the repository use N11's names; examples
  for the other agreed changes are still to come.
- **Whether the `Process` data type goes.** N12 dropped the `processes` property that used it, so
  nothing in the application profile uses it now.
- **OPAF participation (C4).** Bringing the Open Process Automation Forum's control-systems
  modelling into these meetings.
- Carried: Kubernetes profile testing (Prachi, Jay); Tal's OpenAPI→TOSCA generator.

---

**Decisions sought (Part 2):** the `mgmt-address` type (2.1); the `control-host` name, the
control-node workload model, and whether I46 goes in before the tag (2.2); how a derived
relationship type declares its kind (2.3); the container-platform vocabulary and its timing
(2.4); whether to rename `AtRestData` (2.5); and whether `Bash` leaves `core` (2.6).

**Also sought (Part 3):** ratification of the three drafted resolutions (3.1), and whether the
naming amendments are submitted or withdrawn (3.5).

**Input wanted:** on orchestrated credentials (3.2), function portability (3.3) and the calling
convention (3.4).

**After Part 2, what stands between the community and its first tag is two edits, N8 and N9.**
