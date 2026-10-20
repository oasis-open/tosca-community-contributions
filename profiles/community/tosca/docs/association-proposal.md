# What an Administrator View Association May Carry

*Drafted with an AI assistant (Claude); reviewed and submitted by Chris Lauwers.*

**Status:** Proposal — for discussion. Tracked as I54.
**Audience:** TOSCA Community.
**Purpose:** Say what an association relationship in an Administrator View profile may do, so
that two nodes that configure each other can be modeled without a deployment order neither of
them needs.

**Related documents:** [abstract base README](../abstract/base/README.md) — the three
relationship kinds · [technology base profile](../technology/base/profile.yaml) — the
Administrator View's `AssociatesWith` · [modeling-methodology](modeling-methodology.md)

---

## Where the question arises

In the System View, an association is a relationship that imposes no order on the deployment
of its two nodes, and that is all it is. System View relationship types carry no operations:
substitution replaces a node's operations with the substituting template's workflows, and
nothing replaces a relationship's, so an operation on an abstract relationship has nothing to
implement it (A8).

An Administrator View relationship type is different. Its operations are implemented by
artifacts, so what an association may carry there is a real question. The community's
Administrator View base, `community.tosca.technology.base`, declares `AssociatesWith` as *"an
association relationship between two nodes"* and says nothing more.

## The case it must cover

Two components that exchange data with each other: each is configured with the other's
address, or subscribes to the other's signals. Neither needs the other to exist first, and
each needs the other to exist before its configuration can be completed.

- **As two dependencies**, one each way, the orderings contradict: each end must be deployed
  before the other, and a processor that derives its deployment order from dependencies has
  no order to follow. A group of components that exchange signals forms such cycles as a
  matter of course.
- **As an association that does nothing**, the configuration has nowhere to run, so the
  operations that connect the two ends are modeled nowhere.

## The proposal

**An Administrator View association orders neither end, and may carry operations that need
both ends present.**

1. **No order.** An association imposes no order on the deployment or teardown of its ends,
   so associations may form cycles, and a processor must not derive an order from them.
2. **Operations once both ends exist.** An association may carry operations that connect its
   ends: run after both ends are started, and before either is stopped. These are the
   operations that add each end to the other and remove it again — in the operation names
   implementations commonly use, `add_target`, `add_source`, `remove_target` and
   `remove_source`.
3. **No ordered operations.** An association carries none of the operations that run within
   one end's own deployment, before or after it configures — `pre_configure_source` and
   `post_configure_source`, and the like. Those require the other end to exist first, which
   is a dependency. Where a profile declares relationship interface types, the association's
   is a separate type holding only the operations in (2), not derived from the dependency's,
   so a type derived from an association cannot refine its interface into the ordered one.
4. **The guard, restated.** If the source needs its target to exist, or to be configured,
   *before* the source, the relationship is a dependency. If both ends only need each other
   to exist, it is an association, whether or not it carries operations.

`technology.base`'s `AssociatesWith` would state (1) and (2) in its description, and (3) and
(4) would be the rule for the Administrator View profiles derived from it.

## What follows

- **The System View is unaffected.** `InteractsWith` is an association and asserts no
  deployment order, as the abstract base README defines one. Its realizations, in the
  Administrator View, may carry the operations that connect the two ends.
- **Administrator View profiles gain a rule.** The community profiles declare no relationship
  interface types today. When an Administrator View profile does, it follows (3).
- **Independent of I44.** How a derived relationship type declares its kind is a separate
  question; this proposal is about what the association kind means once declared.

## Evidence

One orchestrator implements this: associations order neither end in its generated deploy and
delete workflows, their `add` operations run once both ends are started and their `remove`
operations before either is stopped, and an association implementing an ordered operation is
refused at onboarding. A cycle of associations deploys and tears down; a cycle of
dependencies is refused before any workflow runs.

## Decision sought

Adopt (1) and (2) as the meaning of `technology.base`'s `AssociatesWith`, and (3) and (4) as the
rule for relationship types and interfaces in Administrator View profiles.
