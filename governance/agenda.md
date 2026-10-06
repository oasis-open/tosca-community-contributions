# TOSCA Community — Proposed Agenda (2026-10-07)

**Status:** Draft agenda for 2026-10-07, following 2026-09-30
**Related documents:** [kubernetes-modeling](../profiles/community/tosca/docs/kubernetes-modeling.md) · [association-proposal](../profiles/community/tosca/docs/association-proposal.md) · [modeling-methodology](../profiles/community/tosca/docs/modeling-methodology.md) · [design-patterns](../profiles/community/tosca/docs/design-patterns.md) · [versioning](../profiles/community/tosca/docs/versioning.md) · [open-issues](open-issues.md) · [decision-log](decision-log.md)

The `0.2` is open on `master` and nothing has been decided for it beyond the version string. Last
week pointed at Kubernetes examples without choosing among the four candidates on the table, so
Part 2 asks that question again, with the two items the substitution-mappings example turned up.
Part 3 is what was written since 09-30.

---

## Part 1 — Since 09-30 — 5 min · **presentation**

- **The `0.2` is open** (P8): all seven profiles advertise `0.2` on `master`, with the examples and
  the `io.kubernetes` copy. A template importing a released `0.1` CSAR is unaffected.
- **The release is announced** (R7): on the TOSCA TC list, on LinkedIn by Roberto, and from the
  README, which now has a `Releases` section. The twelve repository watchers were notified when the
  release was published; GitHub has no way to reach the 45 who starred the repository.
- **Requirement refinement** ([#377](https://github.com/oasis-open/tosca-community-contributions/discussions/377)):
  Paul, Tal and I agreed that a refinement need not repeat a mandatory keyname it inherits, which
  §6.4.2 already says. Tal asks for the keyname tables to say so too. Item 3.3.

---

## Part 2 — What the `0.2` is for — 25 min · **decisions sought**

### 2.1 The organizing deliverable — 10 min

On 09-30 the next work was named as Kubernetes examples: the Online Boutique realized with the
generated `io.kubernetes` profile, and the abstract Online Boutique template brought to the revised
profiles. The four candidates set out last week were not ranked: the technology-specific profiles,
the implementation strategy (I43), the artifact calling convention (I10), and the test suite.

**Proposed: organize the `0.2` around the Online Boutique, abstract and realized.** It exercises the
abstract application profile end to end, it is the first realization against a technology profile
the community already has, and [`kubernetes-modeling.md`](../profiles/community/tosca/docs/kubernetes-modeling.md#where-application-level-interaction-should-live)
now names it as the test of how an interaction crosses a substitution boundary: a requirement
mapping carries a `MicroService`'s `interacts-with` onto a requirement of its Pod, so no type
crosses levels, but the Pod needs its peer's address when it is created, and interactions that
form a cycle would form a cycle of dependencies. The realization is not written yet.

**Decision sought:** the Online Boutique, or one of the four.

### 2.2 A size for the abstract platform types — 5 min · *I52*

A `ContainerPlatform` bound to several servers has no property saying how large it is, so a
realization that creates one node per placement learns the number only through
`implementation-details`, as the [cluster example](../examples/substitutions/container-platform-cluster)
does. A function counting a requirement's relationships (I49) does not remove the need, because
the count has nowhere to be reflected.

**Decision sought:** whether to add it in the `0.2`, and on which type: `ContainerPlatform` alone,
or `Platform`, where every platform that spans several hosts would inherit it.

### 2.3 Where examples and substituting templates live — 5 min · *I53*

The profiles have a defined home, `profiles/community/tosca`; the examples do not, so nothing marks
an example that uses the community profiles apart from a contribution demonstrating something
else. Where substituting templates for particular technologies belong, with the profiles or with
the examples, has come up more than once without a decision.

**Decision sought:** who drafts a directory structure, and the answer for substituting templates.

### 2.4 Credential kinds in dash case — 5 min

The kinds that key every credentials map are the one vocabulary in the profiles still in snake
case: `ssh_key` and `ssh_password` on the server platform, `cloud_account` and `ssh_key` on the
virtualization platform, and `x509_cert` and `x509_key` among the kinds N19 adds to the container
platform. §1.2.2 puts the names a model chooses in dash case, metadata keys among them, which is
the convention D2 applied to everything else in the profiles.

**Proposed: `ssh-key`, `ssh-password`, `cloud-account`, `x509-cert` and `x509-key` in the `0.2`**,
with `token` and `kubeconfig` unchanged, and N19's container platform kinds written in the new
spelling when that change goes in, since it edits the same lists. A template importing the `0.1`
is unaffected; one moving to the `0.2` renames the keys it supplies, which is a break the `0.1`'s
compatibility statement allows for. In this repository it is eleven occurrences in the platform
profile, four in its README and fourteen in two proposal documents.

**Decision sought:** rename in the `0.2`.

---

## Part 3 — Proposals written since 09-30 — 15 min · **first reading**

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

### 3.4 Also written

- **A requirement mapped out of a realization must be satisfiable where it ends**
  ([modeling-methodology](../profiles/community/tosca/docs/modeling-methodology.md)): mappings
  impose no type compatibility across the boundary, but the requirement still binds to one
  capability, which must be of its capability type.
- **Corrections to the guides**: an input with no value is unset rather than the string `null`, a
  node filter over a value set in `create` cannot decide under either reading of the
  specification, and the 2.5 profile set contributed on 2026-05-20 is marked as a dated snapshot.

---

## If time permits

- **I44, the relationship kind**: carried until more participants attend. Tal has not been asked.
- **Counting a requirement's relationships (I49)**, now paired with 2.2.
- **Orchestrated credentials (I27, I41)**, **implementations for functions and operations (I43)**,
  **the artifact calling convention (I10)**.
- **A pinned announcement in Discussions**, deferred on 09-30.

---

**Decisions sought (Part 2):** what the `0.2` is organized around (2.1); a size property for the
platform types, and where (2.2); who drafts the repository structure (2.3); and the credential
kinds in dash case (2.4).

**Also sought (Part 3):** whether the refinement erratum goes forward (3.3).
