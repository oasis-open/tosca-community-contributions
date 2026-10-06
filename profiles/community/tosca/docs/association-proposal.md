# What an Association May Carry

*Drafted with an AI assistant (Claude); reviewed and submitted by Chris Lauwers.*

**Status:** Proposal — for discussion. Tracked as I54.
**Audience:** TOSCA Community.
**Purpose:** Say what an association relationship may do, so that two nodes that configure
each other can be modeled without a deployment order neither of them needs.

**Related documents:** [abstract base README](../abstract/base/README.md) — the current
definition of the three relationship kinds · [design-patterns](design-patterns.md) ·
[modeling-methodology](modeling-methodology.md)

---

## The current definition

The abstract base profile defines an association as a relationship that *"carries no
lifecycle, state, or configuration dependency — the association is informational and
neither node's deployment depends on the other"*, and guards against misuse: a relationship
that carries a deployment or configuration dependency is a dependency and derives from
`DependsOn`.

That joins two things that are separate: whether a relationship **orders** its ends, and
whether it **does** anything. An association as defined does neither.

## The case it does not cover

Two components that exchange data with each other: each is configured with the other's
address, or subscribes to the other's signals. Neither needs the other to exist first, and
each needs the other to exist before its configuration can be completed.

- **As two dependencies**, one each way, the orderings contradict: each end must be deployed
  before the other, and a processor that derives its deployment order from dependencies has
  no order to follow. A group of components that exchange signals forms such cycles as a
  matter of course.
- **As an association**, under the current definition, the configuration has nowhere to run.
  The relationship is informational, so the operations that connect the two ends are
  modeled nowhere.

## The proposal

**An association orders neither end, and may carry operations that need both ends present.**

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

The definition in the abstract base README would read: *an association records a relationship
between two nodes that imposes no order on their deployment; it may carry operations that run
once both nodes exist.*

## What follows

- **Nothing in the abstract profiles changes.** `InteractsWith` is already an association and
  asserts no deployment order. Its realizations may now carry the operations that connect
  the two ends.
- **The technology column gains a rule.** The community profiles declare no relationship
  interface types today. When a technology profile does, it follows (3).
- **Independent of I44.** How a derived relationship type declares its kind is a separate
  question; this proposal is about what the association kind means once declared.

## Evidence

One orchestrator implements this: associations order neither end in its generated deploy and
delete workflows, their `add` operations run once both ends are started and their `remove`
operations before either is stopped, and an association implementing an ordered operation is
refused at onboarding. A cycle of associations deploys and tears down; a cycle of
dependencies is refused before any workflow runs.

## Decision sought

Adopt the definition, and the restated guard, for the abstract base README; and adopt (3) as
the rule for relationship interfaces in the technology column.
