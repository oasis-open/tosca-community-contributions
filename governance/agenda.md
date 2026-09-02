# TOSCA Community — Proposed Agenda (2026-09-02)

**Status:** Draft agenda for 2026-09-02, following 2026-08-12
**Related documents:** [abstract-profile-proposed-changes](../profiles/community/tosca/docs/abstract-profile-proposed-changes.md) · [platform README](../profiles/community/tosca/abstract/platform/README.md) · [design-guide](../profiles/community/tosca/docs/design-guide.md) · [open-issues](open-issues.md) · [decision-log](decision-log.md)

This meeting works through
[abstract-profile-proposed-changes.md](../profiles/community/tosca/docs/abstract-profile-proposed-changes.md)
end to end. The document now carries **eight proposals and nine questions**; four
proposals and five questions have never been discussed, and one of them is what the
`0.1` release has been waiting on since 08-05. The items below follow the document's
own order, which is the order the profiles build on each other, so each decision is
taken with its dependencies already settled.

Everything referenced is written up in full. The meeting should not need to reconstruct
an argument from cold.

---

## 1. Credentials in `core` and on the platform types — 15 min · **decisions sought**

**This is the `0.1` blocker.** D11 (agreed 08-05) settled the credential model and
carried an action to write it up in
[#281](https://github.com/oasis-open/tosca-community-contributions/discussions/281) and
incorporate it into the abstract profiles. The write-up exists — as **Section 2.1** of
the proposed-changes document rather than as a comment on #281, whose last comment is
still from March. I8 records that `0.1` waits on this work, so nothing else on the
release path moves until it is agreed.

Two decisions, and they are separable:

- **Section 2.1 — put `CredentialRef` and `NamedCredentialRef` in `core`.** A credential
  in the model is a reference to material, never the material. The argument for `core`
  rather than per-profile is nominal typing: `org.opengroup.opas` declares its own flat
  `Credential`, so a bridge between it and a community credentials map must disassemble
  the value field by field, and only a shared *declaration* removes that. Adopting a type
  from a profile below a standards-derived one is not a deviation from the standard.
  This also settles **Question 3** in part — it is the first shared type to move.
- **Section 2.4 — the per-platform vocabularies.** `credentials` declared once on
  `Platform` keyed by credential kind, each platform type refining the `key_schema` to
  the kinds it accepts: `[ssh_key, ssh_password]` for `ServerPlatform`,
  `[token, cloud_account]` for `VirtualizationPlatform`, `[kubeconfig]` for
  `ContainerPlatform`. §9.4 permits the refinement and a refinement's validation clause
  is considered *in addition to* the parent's, so a derived type narrows and cannot widen.

**Decisions sought:** adopt 2.1 into `core`; confirm the three vocabularies; and confirm
that N8's remaining connection properties ride along with this rather than waiting behind
it. Question 2's resolution — credential typing specific to what is authenticated to —
is unaffected either way.

## 2. One containment relationship, one requirement name — 20 min · *Questions 6 and 7* · **decision sought**

**Section 2.3**, reasoning in **Problems 5 and 6**. The largest change in the document
and the one everything else reads against, which is why it is taken before the
application items.

Three parts, and they can be taken separately:

- **Collapse `HostedOn`, `RunsOn` and `AvailableOn` into `HostedOn`.** They are identical
  but for the capability each accepts, and the profile already marks all three
  `relationship_kind: containment`. This is the Component/Port pattern applied to
  deployment: the capability is the port and names what a node exposes; the relationship
  names intent. Three types differing only in accepted capability state on the
  relationship what the port already states.
- **Declare `host` once on `Base`**, with each child refining the capability. `host` is
  the name TOSCA has used for deployment layering throughout its history; `runs-on` and
  `available-on` are new names for an established concept. §8.4.1 permits the refinement.
- **Add `control-host` on `Platform`** for a platform whose control plane deploys apart
  from what it controls — Kubevirt, and a Kubernetes cluster's control node. **The
  platform README has described this requirement as though it existed since before
  08-12; it does not.** `Platform` declares `host` and `links-to` only, so the README's
  Kubevirt and multi-node cluster models cannot currently be written down. The README now
  marks it as proposed.

**Decision sought:** whether the collapse is adopted, whether `host` moves to `Base`, and
whether `control-host` is the name. **Migration is a clean break**: TOSCA has no aliasing
mechanism — its only `alias` is the YAML anchor convenience in `dsl_definitions` — and
retaining the old types would not help, since they and `HostedOn` are siblings under
`ContainedBy` and refinement requires derivation. Nothing has been released, so there is
no published artifact to stay compatible with; this belongs in the same coordinated cut
as the `0.1` tag.

## 3. The application types — 15 min · *Questions 9 and 5*

Two proposals, taken in dependency order.

- **Section 2.6 — one interaction port.** Abstract `Application` declares no capabilities,
  so nothing can be pointed at it; `Endpoint` and `InteractsWith` sit on `MicroService`
  and `SingleHostApplication` instead, pinned in both to interaction between nodes of the
  *same type*. The proposal declares a property-free `Service` capability on `Application`
  derived from the existing `Partner`, rederives `Endpoint` from it, and rederives
  `InteractsWith` from `AssociatesWith` so that interaction can be modelled without
  asserting deployment order. **Problem 7** has the reasoning. It is worth the group's
  attention that a second profile has already hit this: O-PAS declares a `SignalSource`
  capability and a matching requirement structurally identical to these, because
  there was nothing upstream to derive from.
- **Section 2.7 — rename `SingleHostApplication`.** Named for a cardinality it does not
  constrain, and carrying a `processes` property that collides with the `processes`
  requirement inherited from `Application`. **Problem 4** has the reasoning; the rename to
  `ServerApplication` follows `MicroServiceApplication` and `ServerlessApplication`.

**Decisions sought:** adopt the `Service` capability and the association-kind
`InteractsWith`; adopt the rename and the removal of `processes`.

## 4. Network properties — 5 min

**Section 2.8.** `Network` gains `cidr_block` and `internet_accessible`. The first is what
a network is addressed as, wanted by every realization written against the type. The
second is a *selector* rather than a description — a substitution filter reads it to
choose between reachable and isolated realizations — and defaults to `false` so the safe
case is what an author gets by default. No corresponding problem section: these are
additions, not a defect.

## 5. The `0.1` release — 10 min · *I8 / I26*

What remains after items 1–4, and the sequencing has not changed since 08-12: the
credential model in the abstract profiles, then N8's remaining connection properties,
then the tag. The repository still carries **no tags**, locally or upstream.

Still outstanding from the last agenda and not yet addressed:

- **I26 — `HttpUrl` is not anchored at the end**, so `https://example.com garbage here`
  and `http://999.999.999.999` both pass. Appending `$` is not the fix, since it would
  reject legitimate paths and queries. `core` ships in the `0.1`.
- Whether `core`'s data types carry **test cases**, now that it is the community's
  standard library.

---

## 6. If time permits

- **Question 3 — single source of truth for shared types.** Unblocked since 08-23:
  release automation produces signed CSARs, so tagging `0.1` removes the
  pin-to-a-moving-`master` objection. Item 1 moves the first two types; the question is
  whether the rest follow.
- **Question 8 — whether a control node also hosts workloads.** Now owned by the
  [platform README](../profiles/community/tosca/abstract/platform/README.md#does-a-control-node-also-host-workloads),
  which sets out *set overlap* against *disjoint sets with a property*. The first states
  the topology honestly but cannot be realized, since a requirement mapping cannot
  distribute a subset of bindings; the second can be built today.
- **Two more platform README questions** with no answer yet: how the total node count and
  the control-node count reach a substituting template.
- Carried from 08-12: Kubernetes profile testing (Prachi, Jay); Tal's OpenAPI→TOSCA
  generator; the design-guide walkthrough.

---

**Decisions sought:** adopt Section 2.1 into `core` and confirm the platform credential
vocabularies (#1); the containment collapse, `host` on `Base`, and the `control-host`
name (#2); the `Service` capability and the `ServerApplication` rename (#3); the two
network properties (#4).
