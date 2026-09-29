# TOSCA Community — Proposed Agenda (2026-09-30)

**Status:** Draft agenda for 2026-09-30, following 2026-09-23
**Related documents:** [abstract-profile-proposed-changes](../profiles/community/tosca/docs/abstract-profile-proposed-changes.md) · [modeling-methodology](../profiles/community/tosca/docs/modeling-methodology.md) · [design-patterns](../profiles/community/tosca/docs/design-patterns.md) · [credential-orchestration-proposal](../profiles/community/tosca/docs/credential-orchestration-proposal.md) · [artifact-calling-convention-proposal](../profiles/community/tosca/docs/artifact-calling-convention-proposal.md) · [conformance-clauses](../tests/conformance-clauses.md) · [open-issues](open-issues.md) · [decision-log](decision-log.md)

**The `0.1` is published:** six signed CSARs built from the `v0.1` tag,
[the release](https://github.com/oasis-open/tosca-community-contributions/releases/tag/v0.1). That
closes what the last four meetings were organized around, and it changes what this one is for. Part
1 reports what shipped. Part 2 asks what the community does next, which is the question the release
leaves open. Part 3 is the proposals set aside while the release was cut.

---

## Part 1 — The release, and what changed since 09-23 — 10 min · **presentation**

### The `0.1`

- **Six CSARs, signed, with a checksum manifest:** `core` and the five `abstract.*` profiles, each
  importable by the name and version it advertises. The technology profiles are held back, and
  `technology.base` with them (R5).
- **The release notes** say what the profiles are for, how to verify a download, and that no
  compatibility is promised before `1.0`.
- **What the process has never done is announce a release.** That is item 2.1.

### Written into the profiles since 09-23

- **`StoredData`** replaces `AtRestData` (N18), so the data types are all named for how data is
  delivered.
- **Four functions from Roberto** (#375): `to_lowercase`, `now`, `generate_token` and
  `random_number`. Two needed a fix: an implementation is always called with the argument list,
  even where the signature declares none, and `now` returned a `datetime` where `timestamp` is a
  string in RFC 3339 form.
- **`to_uppercase` and `to_lowercase` on empty and absent values**, and optional outputs in the
  `io.kubernetes` artifacts (#378).
- **Documentation images no longer ship inside the CSARs** (#380), which took the platform
  profile's CSAR from 171 KB to 7.8 KB.

### Recorded

- **The names approved on 09-23** now read as approved: `Host`, `control-host`, `Socket`,
  `ssh_url_to_socket`, `socket_to_ssh_url`, and `ssh_key` among the virtualization platform's
  credential kinds.
- **A proposal for the test suite, the conformance clause index**
  ([`tests/conformance-clauses.md`](../tests/conformance-clauses.md)): how the suite organizes and
  reports its own evidence. What a conformance claim means is the TC's to define, so it is not a
  community agenda item.

---

## Part 2 — What the community does next — 22 min · **decisions sought**

### 2.1 Announcing the release — 5 min · *I8*

The release is public and nobody has been told. The candidates reach different people: the OASIS
list, Discord, and LinkedIn.

**Decision sought:** where the announcement goes, and who writes it.

### 2.2 What the `0.2` is for — 10 min

The `0.1` was the organizing goal for a month. The candidates for the next one, each with someone
who has asked for it:

- **The technology-specific profiles**, which Roberto asked for and which the chair proposed as the
  deliverable after the `0.1`.
- **The implementation strategy** (I43): a profile carries one implementation per signature, and
  which one belongs there is unsettled. D14 held it out of the `0.1` rather than answering it.
- **The calling convention** (I10), which the duplicate `Bash` artifact type waits on.
- **The test suite**, which has had no active contributor since June and carries 35 open issues.
  I19 asks for it to be described in the governance documents at all.

**And the version the profiles carry.** Every profile still advertises `0.1`, the version the
released CSARs carry, so anyone tracking `master` imports a name that no longer says what they
get. Bumping the seven profiles to `0.2` separates the release from the work; the rule for when a
version bumps and what an unreleased version means has never been written down, which I8 records
as the one unbuilt part of the release process. A rule is proposed in
[`docs/versioning.md`](../profiles/community/tosca/docs/versioning.md).

**Decisions sought:** which of these the next release is organized around, one and not four; and
the versioning rule, with the bump to `0.2` that follows from it.

### 2.3 How a derived relationship type declares its kind — 5 min · *I44* · [#363](https://github.com/oasis-open/tosca-community-contributions/discussions/363)

Carried since 09-09 and not reached twice. The base relationship types carry
`metadata: {relationship-kind: …}`, which is not inherited and which the specification says should
not affect runtime behavior. The options are unchanged: redeclare it on every derived type, drop it
and let derivation carry the kind, ask for a `kind` keyname in 2.1, document it as a convention that
does not travel, or give the kind through `directives` on a requirement assignment.

**Decision sought:** what the profiles do, now that the release no longer constrains the answer.

### 2.4 The container platform's credential kinds and URL schemes — 2 min · *I29*

Deferred past the `0.1` deliberately, since widening a `key_schema` breaks nothing downstream. It
needs an owner and a target release rather than a decision today.

---

## Part 3 — Outstanding proposals — 15 min · **status, and what each needs**

### 3.1 A worked substitution-mappings example, and an error in the specification · *I51*

Roberto asked for an example after trouble with requirements in substitution mappings. Building one
turned up an apparent error in the specification's use of the `UNBOUNDED` keyword, which the chair
presents with the example.

**Decision sought:** whether it is an erratum (P4) or a misreading.

### 3.2 Three drafted resolutions awaiting ratification · *I13 / I16(c) / I17*

**Carried past seven meetings without being read.** Each needs a yes or a no, not a discussion.

- **I17 — the monitoring and security patterns**
  ([`design-patterns.md`](../profiles/community/tosca/docs/design-patterns.md)).
- **I16(c) — how deep the type hierarchies should go**
  ([`design-patterns.md`](../profiles/community/tosca/docs/design-patterns.md)). N17's "permission
  at the base, restriction below it" is a partial answer.
- **I13 — no `type-of-node` function**
  ([`modeling-methodology.md`](../profiles/community/tosca/docs/modeling-methodology.md)).

### 3.3 Orchestrated credentials · *I27 / I41* · [proposal](../profiles/community/tosca/docs/credential-orchestration-proposal.md)

A credential the orchestrator creates rather than references. Open: which profile the `Credential`
capability belongs in, and whether the orchestrated-secret node types belong in the abstract
profiles at all. I29's certificate kinds need the trust anchor I41 describes.

### 3.4 Implementations for functions and operations · *I43* · [#365](https://github.com/oasis-open/tosca-community-contributions/discussions/365)

Implementations vary by the target platform's technology, by the orchestrator and by the tooling,
for operations as much as for functions, and a profile can name only one. Roberto prefers a list of
implementations per signature to repeated signatures. Both directions need a language extension.
D14 kept the implementations in `core` for the `0.1`, which was a deferral rather than an answer.

### 3.5 The artifact calling convention · *I10* · [proposal](../profiles/community/tosca/docs/artifact-calling-convention-proposal.md)

One structured document of inputs in place of a variable per input, each artifact type declaring its
own channel. Roberto's alternative is a `Bash` artifact type per convention, or a keyname naming the
convention. Tal's input is wanted, since that implementation uses standard input and output.

### 3.6 Counting a requirement's relationships · *I49* · [#372](https://github.com/oasis-open/tosca-community-contributions/discussions/372)

Pairs of realizations that differ only in whether an optional requirement is bound can be told apart
today only by reading a value on the target, which forces the requirement to name a target node type
so the read can be validated. The discussion proposes a built-in that counts the relationships
instead. **Input wanted:** the name, whether a missing index means all relationships, and whether
§15.1 should say requirements are resolved before a candidate is chosen.

---

## If time permits

- **Substitution filters against the revised types (I32).**
- **Examples exercising the agreed changes.**
- **Whether the `Process` data type goes**, now nothing uses it.
- **OPAF participation (C4).**
- Carried: Kubernetes profile testing (Prachi, Jay); Tal's OpenAPI→TOSCA generator.

---

**Decisions sought (Part 2):** where the release is announced (2.1); what the `0.2` is organized
around and the versioning rule that opens it (2.2); and how a derived relationship type declares
its kind (2.3).

**Also sought (Part 3):** whether the `UNBOUNDED` use is an erratum (3.1), and ratification of the
three drafted resolutions (3.2).
