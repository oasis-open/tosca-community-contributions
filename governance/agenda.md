# TOSCA Community — Proposed Agenda (2026-09-23)

**Status:** Draft agenda for 2026-09-23, following 2026-09-16
**Related documents:** [abstract-profile-proposed-changes](../profiles/community/tosca/docs/abstract-profile-proposed-changes.md) · [modeling-methodology](../profiles/community/tosca/docs/modeling-methodology.md) · [design-patterns](../profiles/community/tosca/docs/design-patterns.md) · [credential-orchestration-proposal](../profiles/community/tosca/docs/credential-orchestration-proposal.md) · [artifact-calling-convention-proposal](../profiles/community/tosca/docs/artifact-calling-convention-proposal.md) · [spec-naming-conventions-proposal](../profiles/community/tosca/docs/spec-naming-conventions-proposal.md) · [open-issues](open-issues.md) · [decision-log](decision-log.md)

The same three parts as last week. **First, what changed since 09-16**, presented rather than
discussed. **Second, the decisions the `0.1` still waits on**, now fewer: last week settled the
management address (N16) and the hosting capability (N17). **Third, the outstanding proposals**,
with what each one needs next.

**This is the last meeting in September, the month the chair set for the release.** What is left
is the control-plane requirement, the relationship kind, three smaller questions, and the release
itself, which has not yet had a slot: the version string, what the release promises about
compatibility, and how it is announced. Part 2 carries all of them.

**The three parts fill the hour, and Part 2 is the one to protect.** Part 3 gives way if the
presentation runs long. Each of its items links the document to read beforehand.

---

## Part 1 — What changed since 09-16 — 10 min · **presentation**

### Decided on 09-16

- **N16 — `mgmt-address` is a URL.** A URL type in `core`, with `SshUrl` and `HttpUrl` derived from
  it; `Platform` declares `mgmt-address` once, and each platform type narrows the scheme as it
  narrows the credential kinds. Supersedes N7. `Url` and `SshUrl` are in `core` since 09-16; the
  property follows with the two URL functions and the realizations that need them.
- **N17 — one hosting capability on `Platform`.** Derived platform types restrict what they host,
  rather than the base differentiating it. Amends N9, and settles the relationship-type collapse N9
  left open. It goes into the profiles with N9.

To be written into the profiles with those two: the names of the two URL functions `core` gains
(N16), and the name of the single hosting capability (N17).

### Written into the profiles since 09-16

- **N8, `credentials`** — declared on `Platform`, and narrowed on the server, virtualization and
  container platforms to the credential kinds each accepts.

### Discussions and errata

- **[#365](https://github.com/oasis-open/tosca-community-contributions/discussions/365)** — the
  chair's reply on function portability: what the specification already permits, what each
  approach runs into, and a proposal for the `0.1`.
- **[oasis-tcs/tosca-specs#376](https://github.com/oasis-tcs/tosca-specs/issues/376)** — the
  positional function refinement rules, filed as an erratum after last week's discussion.

---

## Part 2 — The decisions the `0.1` still waits on — 35 min · **decisions sought**

### 2.1 The control plane — 10 min · *Questions 6 and 8*

N9 settled `host`; N17 settled what it targets. A platform whose control plane deploys apart from
what it controls, such as Kubevirt or a multi-node Kubernetes cluster, needs a second requirement,
and last week's view was that two requirements is the right model.

- **The name.** `control-host` reads as `host`'s sibling. `runs-on` is unavailable, since it
  already means where an application executes.
- **Question 8 — whether a control node also hosts workloads**
  ([platform README](../profiles/community/tosca/abstract/platform/README.md#does-a-control-node-also-host-workloads)).
  *Set overlap* states the topology honestly but cannot be realized, since a requirement mapping
  cannot distribute a subset of bindings. *Disjoint sets with a property* can be built today.

**Decisions sought:** the name, and which workload model the profiles adopt.

### 2.2 How a derived relationship type declares its kind — 8 min · *I44* · [#363](https://github.com/oasis-open/tosca-community-contributions/discussions/363)

The base relationship types carry `metadata: {relationship_kind: …}`, which is not inherited and
which the specification says should not affect runtime behavior. The options: redeclare it on every
derived type with one case convention; drop it and let derivation carry the kind; ask for a `kind`
keyname in 2.1; document it as a convention that does not travel; or give the kind through
`directives` on a requirement assignment, Roberto's option.

Last week added two positions. The chair's is that the kind belongs to type design rather than
template design, with a wider vocabulary of kinds aligned with UML's relationships floated.
Roberto's is that the lifecycle semantics across a relationship should be standardized. Both are
language changes, so what the `0.1` ships is one of the first, second or fourth.

**Decision sought:** what the `0.1` ships, and its case convention.

### 2.3 The container platform: credential kinds and URL schemes — 5 min · *I29*

- **Credential kinds:** `[kubeconfig, token, x509_cert, x509_key]`, following from what each
  connection opens, with the SSH kinds left on the `ServerPlatform` hosting the platform.
- **URL schemes,** new since N16: `https`, `tcp` and `unix`, as Section 2.4 proposes, covering a
  Kubernetes API server, a remote Docker daemon and a local socket.

**Decisions sought:** both vocabularies, and whether they go into the `0.1` or after it. Widening a
`key_schema` breaks nothing downstream; narrowing it later would.

### 2.4 `AtRestData`'s name — 3 min · *I45*

"At rest" is a security term, where the data profile's other five types are named for how data is
delivered. `StoredData` and `PersistentData` read alongside `BatchData`, `StreamingData` and
`EventData`.

**Decision sought:** rename before the `0.1`, or keep the name. After the tag a rename breaks.

### 2.5 Does `Bash` leave `core`? — 2 min · *I10*

No profile in the repository names `core`'s `Bash`, and `technology.base` declares the one that is
wanted. Last week's proposal of a `Bash` type per calling convention (3.4) is a reason to settle
where artifact types live before adding more of them.

**Decision sought:** delete `core`'s `Bash` for the `0.1`, or keep it until the calling convention
is settled.

### 2.6 The release — 7 min · *I8*

The release has not had a slot of its own, and three things about it need the group:

- **The version string.** `0.1` or `0.1.0`. The chair's proposal: semantic versioning, with a
  missing patch number read as zero. Whether an import of `0.1` should then match a profile named
  `0.1.0` is part of the same question.
- **What it promises.** The chair's proposal: no compatibility commitment before 1.0, stated in the
  release notes, since the profiles will change as they are used.
- **How it is announced,** and to whom.

**Decisions sought:** all three, so the tag can follow once N8 and N9 are written.

---

## Part 3 — Outstanding proposals — 15 min · **status, and what each needs**

### 3.1 Three drafted resolutions awaiting ratification · *I13 / I16(c) / I17*

**Carried past six meetings without being read.** Each needs a yes or a no, not a discussion.

- **I17 — the monitoring and security patterns**
  ([`design-patterns.md`](../profiles/community/tosca/docs/design-patterns.md)).
- **I16(c) — how deep the type hierarchies should go**
  ([`design-patterns.md`](../profiles/community/tosca/docs/design-patterns.md)). N17's "permission
  at the base, restriction below it" is a partial answer.
- **I13 — no `type-of-node` function**
  ([`modeling-methodology.md`](../profiles/community/tosca/docs/modeling-methodology.md)).

### 3.2 Orchestrated credentials · *I27 / I41* · [proposal](../profiles/community/tosca/docs/credential-orchestration-proposal.md)

A credential the orchestrator creates rather than references. Open: which profile the `Credential`
capability belongs in, and whether the orchestrated-secret node types belong in the abstract
profiles at all. I29's certificate kinds need the trust anchor I41 describes.

### 3.3 Implementations for functions and operations · *I43* · [#365](https://github.com/oasis-open/tosca-community-contributions/discussions/365)

Last week agreed the problem is general: implementations vary by the target platform's technology,
by the orchestrator and by the tooling, for operations as much as for functions, and a profile can
name only one. Roberto preferred a list of implementations per signature to repeated signatures.
Both directions need a language extension. **Input wanted:** whether `core` ships signatures only
for the `0.1`, as the reply on #365 proposes.

### 3.4 The artifact calling convention · *I10* · [proposal](../profiles/community/tosca/docs/artifact-calling-convention-proposal.md)

One structured document of inputs in place of a variable per input, each artifact type declaring
its own channel. New since last week: Roberto's proposal of a `Bash` artifact type per convention,
or a keyname naming the convention. Tal's input is wanted, since that implementation uses standard
input and output.

### 3.5 The §1.2.2 naming amendments · *I39* · [proposal](../profiles/community/tosca/docs/spec-naming-conventions-proposal.md)

**Decision sought, and five minutes is enough:** submit on the errata track (P4), or withdraw.

---

## If time permits

- **Substitution filters against the revised types (I32).**
- **Examples exercising the agreed changes.**
- **Whether the `Process` data type goes**, now nothing uses it.
- **OPAF participation (C4).**
- Carried: Kubernetes profile testing (Prachi, Jay); Tal's OpenAPI→TOSCA generator.

---

**Decisions sought (Part 2):** the control-plane requirement's name and workload model (2.1); how a
derived relationship type declares its kind (2.2); the container platform's credential kinds and URL
schemes (2.3); `AtRestData`'s name (2.4); whether `Bash` leaves `core` (2.5); and the release's
version string, compatibility statement and announcement (2.6).

**Also sought (Part 3):** ratification of the three drafted resolutions (3.1), and whether the
naming amendments are submitted or withdrawn (3.5).

**After Part 2, what stands between the community and its first tag is writing N8 and N9.**
