# TOSCA Community Design Patterns

**Status:** Current practice.
**Audience:** TOSCA Community
**Purpose:** The recurring modeling patterns the community profiles are built
from. Each pattern names a problem that comes up across profiles and the shape
of type definitions that answers it. The methodology these patterns are applied
within — the Model Continuum, translating between levels, deploying abstract
services — is in the [modeling methodology](modeling-methodology.md).

**Related documents:** [README](README.md) · [modeling-methodology](modeling-methodology.md) · [profile-organization](profile-organization.md) · [decision-log](../../../../governance/decision-log.md) · [open-issues](../../../../governance/open-issues.md)

---

## Component/Port Pattern

TOSCA uses a **Component/Port** pattern where a component’s touch
points for interacting with other components are modeled separately
from that component using *port* abstractions. Using TOSCA, components
are modeled using *Node Types* and the ports of those components are
modeled using the following two different abstractions associated with
node types:
- Capabilities: for functionality exposed by a component and usable by
  other components.
- Requirements: for dependencies of one component on functionality
  exposed by other components.

**Naming principle.** Capability type names should describe the
*functionality a component exposes*; relationship type names should
describe the *semantics of the dependency* — the intent of the source
node toward the target — and not the mechanism used to realize it.
Intent-revealing names (`Monitors`, `ManagedBy`, `RegistersWith`,
`HostedOn`) are preferred over mechanism-flavored names (`ConnectsTo`,
`BindsTo`, `LinksTo`). This keeps service templates readable: the reader
should understand *why* two nodes are related from the type name alone.

**Data placement.** A port is not only the structural touch point between
two components; it is where a component's *exposed contract* lives. The
properties and attributes a *consumer* reads across a binding — the
coordinates it needs to use the exposed functionality — belong on the
**capability**, not on the node. State that is internal to how the
component is realized or deployed stays on the node.

Decide by asking: *does a bound consumer read this value?* If a node bound
through a requirement reads it (through the capability), it is part of the
exposed contract and belongs on the capability; if only the component's own
operations use it, it is realization detail and stays on the node.

This is what lets the Component/Port pattern support substitution. A
consumer that reads the contract from the capability (using the TOSCA Path
`CAPABILITY` step, e.g. `[SELF, RELATIONSHIP, <requirement>, CAPABILITY,
<attribute>]`) depends on the *capability type*, not on the node type behind
it. Any node that advertises the capability — a different realization, or a
substituting service template — then satisfies the consumer unchanged. Put
the contract on the port and the implementation behind it becomes swappable;
leave it on the node and every consumer is coupled to that node type.

For example, a certificate authority exposes its issuing endpoint, trust
root, and enrolment credential on a *certification* capability rather than
on the (deployment-specific) CA node, so an enrolling node works against any
CA realization; an OCI registry exposes its endpoint, scheme, TLS trust
anchor, and deposit credential on its *registry* capability, so a publisher
pushes without knowing whether the registry is zot, Harbor, or a hosted
service.

When a base capability has several realizations, a second question follows:
*which* capability carries a given value? Decide by whether it is universal or
realization-specific. A contract **every** realization exposes belongs on the
**base capability**; a value **specific to one** realization belongs on a
**capability derived from** that base — so realizations differ without the base
accumulating every realization's fields. This is the same derive-to-specialize
discipline the pattern applies to type *naming*, now applied to the contract's
*data*: enrich the base for what is common, derive a capability for what is not.

**Secrets are references, not values.** Related to data placement, but
broader: a component's model — its properties and attributes, and the inputs
and outputs that flow through them — must carry *references* to secret
material, never the material itself. A password, token, or private key belongs
in a vault or a mounted file on the executing host; the model carries only a
**path or name** the runtime resolves there. A secret placed in a property, an
attribute, or an inputs file leaks: inputs are often committed to source
control, and attributes surface in deployed-model state where any consumer can
read them back. Where a secret's *value* originates is a separate choice — an
operator may supply it out of band (a reference to an existing vault entry),
or, when the orchestrator controls both ends of a channel, an operation may
generate it directly into a vault and hand back only the path. Either way the
model sees a reference; the value never becomes a modeled value.

The Component/Port pattern defines *common* categories of
functionality that are typically exposed by all components. It then
attempts to define *common* capability types and *common* relationship
types to represent each of these categories of functionality. Note
that this pattern is inspired by the [ONF Core Information
Model](https://opennetworking.org/software-defined-standards/models-apis/),
the [TMF Open Digital Architecture](https://www.tmforum.org/oda/), and
other modeling efforts that use a similar approach. These standard
categories of functionality are shown in the following picture:

![Component/Port Pattern](../images/component-port.png?raw=true)

- **Runtime environment**: most if not all TOSCA nodes are contained
  by (*hosted on*) another node and their lifecycle is determined by
  the lifecycle of the containing node. This containment dependency is
  expressed using an *execution environment requirement* that must be
  fulfilled by a corresponding *execution environment capability* of
  the containing node. Nodes that can *host* other nodes typically
  have their own *runtime environment requirement*.
- **Core functionality**: the main function of a TOSCA node is to
  provide a specific set of features or functionality to other
  nodes. This is expressed using a *core functionality capability*.
  Other nodes will define requirements for this functionality.
- **Management**: many TOSCA nodes are matched with a corresponding
  management tool. This relationship is expressed as a *management
  requirement* of the managed TOSCA node rather than as a *management
  capability* to express potential deployment dependencies: if the
  management tool is used to configure the TOSCA node, the management
  tool must be deployed before the managed node can be fully deployed.
  Note that for management tools, the management functions are exposed
  as their *core functionality capability*. Because management is
  modeled as a requirement of the managed node, a *reverse* "manages"
  capability/relationship on the management tool is **not** needed and
  should be avoided — it duplicates the same dependency in the opposite
  direction.
- **Monitoring**: many TOSCA nodes are matched with a corresponding
  monitoring tool. The monitored node exposes an *observability
  capability*; the monitoring tool declares a *monitoring requirement*
  that targets it. This is a *dependency* relationship (the monitored
  node must be deployed and observable before monitoring can attach),
  so the monitoring relationship derives from `DependsOn`. Modeling
  observability as a capability of the *monitored* node — rather than as
  a capability of the monitoring tool — keeps the direction consistent
  with management: the touch point lives on the node being acted upon.

  > **Proposed resolution for issue I17.** Formalizes the monitoring
  > pattern that was discussed in the TOSCA TC but never written down.

- **Security**: securing access to a node is not one concern but
  several, each modeled with its own capability/relationship pair. Note in
  particular that *authentication* (proving **who** a consumer is) and
  *authorization* (**what** that consumer may do) are distinct concerns and
  should not be conflated, even though a bearer credential often fuses them:
  - *Perimeter protection* — a node exposes a capability indicating it
    can be fronted by a security control (firewall, gateway); the
    protected node declares a requirement targeting it. (A coarse,
    network-layer authorization boundary.)
  - *Authentication / credentials* — a node exposes a capability
    representing the credential(s) by which a consumer **proves its
    identity** to access it; the consumer declares a requirement that it
    is authenticated using that credential. This establishes *who* the
    consumer is, not *what* it may do. A worked realization — the port, the
    obligation advertising it creates, and node types for credentials with a
    lifecycle — is proposed in
    [credential-orchestration-proposal.md](credential-orchestration-proposal.md).
  - *Authorization* — what an authenticated principal is **permitted to
    do**. A credential proves identity; authorization is the policy
    applied to that identity. Today this is usually *coarse* — holding a
    bearer credential grants access, and perimeter controls gate at the
    network layer — so it rides on the credential and perimeter patterns.
    *Fine-grained* authorization (roles / scoped permissions modeled as
    their own capabilities and requirements, so that "identity X may do A
    but not B" is expressible) is a further, less-developed sub-pattern.
  - *Identity / registration / trust* — a node (a registry or trust
    store) exposes a registration capability; devices and services
    declare a *registration requirement* (e.g. `RegistersWith`) so that
    their signed requests can later be verified by relying parties.

  > **Proposed resolution for issue I17.** Replaces "this pattern needs
  > further work" by splitting security into perimeter, authentication,
  > authorization, and identity/trust sub-patterns — keeping authentication
  > and authorization distinct rather than fused under "credentials."

**The category list is open-ended.** The categories above are the
*common* ones, not an exhaustive set. Other recurring cross-cutting
categories follow the same pattern and may warrant their own common
capability and relationship types — for example *provisioning* (a node
built from an image or package source), *networking* (attachment to
hosts and networks), and *routing* (directing traffic to a target). New
categories should be introduced deliberately, documented here, and given
capability and relationship types that follow the naming principle
above.

As stated earlier, the TOSCA Community uses this pattern to define common
capability types and common relationship types for these various
categories of functionality. These types are discussed next.

### Best Practices

> **Proposed resolutions for issue I16.** The three questions below were
> previously open; the recommendations are proposed for community
> ratification. Related to I4 (abstract-vs-minimal types). Since they
> were drafted, decision N9 has settled question 1 and decision N10 the
> question of when to derive, and questions 2 and 3 are worded to match
> N10. How deep type hierarchies should go is answered in part by the
> [One Port, Many Consumers](#one-port-many-consumers) pattern below.

**1. Where should the capability↔relationship constraint be declared —
`valid_capability_types`, `valid_relationship_types`, or both?**

Declare it in **one** place, not both. The recommended convention:

- Put `valid_relationship_types` **only on the three base capability
  types** (`Container`, `Feature`, `Partner`), where it enforces the
  containment / dependency / association *kind* gate.
- Put `valid_capability_types` **on relationship types** to point each
  relationship at the specific capability it targets.

Restating both on every derived type is redundant, and — under TOSCA's
nominal typing — invites the two lists to drift out of sync.

**2. When should a new derived relationship or capability type be
defined, versus reusing a base type?**

Never use a base type — `Container`, `Feature`, `Partner` or the base
relationship types — directly in a profile. Derive one that names the
intent, even when it adds nothing to its parent (decision N10): the name
states what the connection is for, and it keeps discrimination possible
if a second type is later derived from the same parent.

Beneath that named type, derive a further type when at least one of
these holds:

1. A **semantically clearer name** improves the readability of profiles
   and templates — the name reveals a function or an intent that the
   parent type does not.
2. **Additional properties or attributes** are needed on the
   relationship or capability.
3. **Additional inputs or operation implementations** are needed on a
   relationship interface.
4. **Additional interfaces** are needed on the relationship.

A clearer name means a different function, not a different consumer. If
the type would differ from its parent only in which nodes it connects,
do **not** derive it; restrict the parent where it is used instead, as
the [One Port, Many Consumers](#one-port-many-consumers) pattern below
describes.

**3. If a specific capability and a specific relationship to it are
needed, derive new types or specialize the named types in place?**

Follow from question 2: if a case in (1)–(4) applies, derive the types.
Otherwise, reuse the named types and constrain them where they are
used: `valid_source_node_types` in the capability definition of the
target node type, and `node` in the requirement definition of the
source node type. This keeps the type hierarchies shallow and avoids a
proliferation of near-identical types.

## One Port, Many Consumers

> **Proposed resolution for issue I46**, and a partial answer to how
> deep type hierarchies should go (I16). Generalizes the hosting
> amendment in [Section 2.3 of the abstract-profile proposal](abstract-profile-proposed-changes.md#23-communitytoscaabstractbase--one-containment-relationship-one-requirement-name);
> the reasoning is in its
> [Problem 8](abstract-profile-proposed-changes.md#problem-8--three-hosting-capabilities-that-every-platform-exposes).
> Not yet discussed by the community.

**Problem.** Several kinds of node often use the same function of a
target. A platform places applications, data, networks and other
platforms; a network carries traffic for whatever attaches to it. The
temptation is to give each kind of consumer a capability type of its
own, so that the capability says both what is offered and who may use
it. That repeats what the consumer's node type already says, and it
costs three things:

- **It does not tell targets apart.** Declared on a base target type,
  every capability is inherited by every type derived from it, and a
  derived type cannot remove an inherited capability. Every target then
  advertises every kind of use, whether or not it supports it.
- **A consumer cannot ask for more than one.** A requirement names a
  single capability, so a consumer has no way to ask for a target that
  also serves another kind of consumer.
- **The vocabulary is closed.** Each new kind of consumer needs a new
  capability on the target, and until it has one it borrows a capability
  named for someone else.

**Shape.** One capability per function, exposed once by the base target
type with no restriction on its consumers, and narrowed by the derived
target types that accept fewer:

```yaml
capability_types:
  Host:                      # one named type per function (N10)
    derived_from: Container

node_types:
  Base:
    requirements:
      - host: { capability: Host, relationship: HostedOn }

  Platform:
    derived_from: Base
    capabilities:
      host:
        type: Host           # accepts every kind of consumer

  ServerlessPlatform:
    derived_from: Platform
    capabilities:
      host:
        valid_source_node_types: [ Application ]   # accepts fewer
```

(The hosting names follow the Section 2.3 proposal, where `Host` is a
placeholder. The `ServerlessPlatform` restriction illustrates the
mechanism and is not proposed for that type.)

The rules behind the shape:

1. **A capability names the function offered, not who may use it.** This
   is the naming principle of the Component/Port pattern applied to its
   consequence. What the consumer is, its node type already says, and
   every relationship already knows its source. The test for whether two
   uses share a port is whether they use the *same function* of the
   target. A platform's hosting and its attachment to a network are
   different functions, and are different ports.

2. **Permit at the base; restrict by derivation.** Refinement narrows
   (§5.1.3). A derived type may narrow `valid_source_node_types` (§8.1,
   §8.2.1)[^errata], a property's validation (§9.4) and a requirement's
   `count_range` (§8.4.1), and a `node_filter` in a requirement
   definition is applied in addition to its parent's. None of them can
   be widened. A restriction written into a base type therefore binds
   every type beneath it and can never be lifted, while a permission
   granted there can be withdrawn by any derived type that needs to.
   Declare at the base only the restrictions that hold for everything
   beneath it. The modeling methodology applies the same rule to
   [node filters written into types](modeling-methodology.md#make-placement-decisions).

3. **Restrict at the narrowest scope that holds.** A restriction on what
   may be placed where can be declared at three levels, each binding
   more than the next:

   | declared on | binds |
   |---|---|
   | the capability *type* | every node type that exposes the capability, in every profile |
   | a capability definition in a node type | that node type and every type derived from it |
   | a `node_filter` in a requirement assignment | one consumer's placement in one template |

   The first is the strongest restriction TOSCA offers and the least
   often right; a base profile should use it only for a restriction that
   holds wherever the capability appears.

4. **When one kind of consumer needs its own contract, derive beneath
   the shared capability, not beside it.** If placing data ever needs a
   property that placing an application does not, derive a capability
   type from `Host` that carries it. A target that offers it refines its
   `host` capability to the derived type (§8.2.1); a consumer that needs
   it refines its requirement to the derived type (§8.4.1). Consumers
   that ask for `Host` still bind, since a requirement is satisfied by a
   capability of the type it names or of a type derived from it. This is
   the same discipline as data placement in the Component/Port pattern:
   enrich the base for what is common, derive for what is not.

**Limits.**

- **Eligibility is checked per consumer.** A requirement states only its
  own consumer's eligibility; nothing lets one consumer ask for a target
  that would also accept another kind. Where two consumers must share a
  target, each is checked against the same capability as it binds, and a
  target that has narrowed one of them away fails that binding.
- **Restriction is by nominal type.** `valid_source_node_types` accepts a
  listed type and anything derived from it. Listing base consumer types
  lets every consumer derived from them qualify, including ones defined
  in later profiles; a consumer of an unrelated type does not, whatever
  it resembles.

[^errata]: §8.2.1's wording, read literally, measures a capability
    refinement against the capability type rather than the definition in
    the parent node type, which would let a derived node type widen a
    list its parent narrowed. That contradicts §5.1.3, §8.1 and the
    parallel §8.4.1, and is raised as errata in
    [oasis-tcs/tosca-specs#371](https://github.com/oasis-tcs/tosca-specs/issues/371).
