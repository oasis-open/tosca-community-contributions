# TOSCA Community Design Patterns

**Status:** Current practice.
**Audience:** TOSCA Community
**Purpose:** The recurring modeling patterns the community profiles are built
from. Each pattern names a problem that comes up across profiles and the shape
of type definitions that answers it. The methodology these patterns are applied
within — the Model Continuum, translating between levels, deploying abstract
services — is in the [design guide](design-guide.md).

**Related documents:** [README](README.md) · [design-guide](design-guide.md) · [profile-organization](profile-organization.md) · [decision-log](../../../../governance/decision-log.md) · [open-issues](../../../../governance/open-issues.md)

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
> ratification. Related to I4 (abstract-vs-minimal types).

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

Derive a new type when at least one of these holds:

1. A **semantically clearer name** improves the readability of profiles
   and templates (the name reveals intent that the base type does not).
2. **Additional properties or attributes** are needed on the
   relationship or capability.
3. **Additional inputs or operation implementations** are needed on a
   relationship interface.
4. **Additional interfaces** are needed on the relationship.

If none of these apply — the type would differ only in which nodes it
connects — do **not** derive a new type.

**3. If a specific capability and a specific relationship to it are
needed, derive new types or specialize the base types in place?**

Follow from question 2: if a case in (1)–(4) applies, derive the types.
Otherwise, reuse the base types and constrain them at the point of use
with `valid_source_node_types` / `valid_target_node_types` in the
capability and requirement definitions. This keeps the type hierarchies
shallow and avoids a proliferation of near-identical types.
