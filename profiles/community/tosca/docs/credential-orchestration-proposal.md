# Credential Orchestration

**Status:** Proposal — for discussion. The data type half is settled (decision D13); what is
proposed here is the capability and the node types.
**Audience:** TOSCA Community
**Purpose:** Model credentials the orchestrator **creates**, as distinct from credentials it is
given. Raised by Tal on discussion #281, against the observation that a data type alone does not
cover a credential with a lifecycle.

**Related documents:** [README](README.md) · [design-patterns](design-patterns.md) · [profile-organization](profile-organization.md) · [abstract-profile-proposed-changes](abstract-profile-proposed-changes.md) · [decision-log](../../../../governance/decision-log.md) · [open-issues](../../../../governance/open-issues.md)

---

## What is already settled

A credential in a model is a **reference** to material, never the material. `CredentialRef` carries
the path to where the material is retrieved and, where one is needed, a `name`;
`NamedCredentialRef` derives from it and makes `name` mandatory. A node needing credentials declares
a **map** of them keyed by credential kind, and each derived type refines the map's `key_schema` to
the kinds it accepts — the key *is* the kind, so no entry carries a type field.

Agreed at the 2026-09-02 community meeting as decision D13, and proposed for
`community.tosca.core` in Section 2.1 of the
[abstract-profile proposal](abstract-profile-proposed-changes.md).

## What this proposes

**Two origins, and only one of them is a value.** A credential the orchestrator does not own — a
cloud API token, a registry password — is supplied from outside and is an inline `CredentialRef`.
A credential that comes into being during deployment is not: deploying a virtual machine means
generating a key pair and handing the public half to the provider along with the request. It is
issued, renewed, revoked and access-controlled, which is to say it has a lifecycle, and in TOSCA a
thing with a lifecycle is a **node**.

**This models authentication, not authorization.** A credential carries *who* a consumer is and
its proof of that. *What* an authenticated principal is permitted to do is a separate concern and
is not modelled here. A bearer credential fuses the two in practice — holding it both identifies
you and admits you — which is why the distinction is stated rather than left to the reader: the
`Credential` port is not an access-control mechanism. This is the *authentication* sub-pattern of
the security section of the [design patterns](design-patterns.md#best-practices), and the proposal
below is a worked realization of it.

```yaml
capability_types:
  Credential:
    description: >-
      Advertises the ability to act as a credential. The material is published
      here, keyed by credential kind, so that a consumer reads it through the
      port and stays independent of the node type providing it.
    derived_from: Feature
    properties:
      credentials:
        type: map
        key_schema: { type: string }
        entry_schema: { type: CredentialRef }
        required: false
```

**The value type is `CredentialRef` and the port is `Credential`**, so each name belongs to one
entity and a reader needs no context to tell which is meant. `Ref` is substance rather than
decoration: the value carries a *reference* to secret material and never the material itself, so the
name states the property that governs how it may be used.

**Advertising the port obliges the node to publish material, in the form the data type defines.** A port that
publishes nothing is a promise the node cannot keep, since a consumer binds it precisely to read
through it. A consumer binds generically — `capability: Credential`, working against any credential
node — or specifically, pinning the node type when it needs a particular kind.

**The map is declared as a property, and that is what makes the port a contract.** Every property
has an automatically reflected attribute of the same name, so one declaration yields both views, and
both are needed because material reaches a port two ways. A node that **mints** its material writes
the attribute in `create`, along the same path a consumer reads. A node that **receives** material
from the model has it assigned as a property under `capabilities.<port>.properties`. The declaration
is optional, because a minting advertiser has nothing to assign. A consumer reads it the same way in
both cases and never learns which origin it was.

**A node type whose material serves more than one kind splits into subtypes**, and the reason is a
constraint of the language rather than a preference. For minted material the map is written by
`create`, so at the time a requirement is matched it is unset: a `node_filter` over it evaluates to
null and drops out rather than rejecting, and the kind cannot be constrained that way. Only the node
*type* is known early enough. The same bytes that serve as a password to whoever sends HTTP Basic
serve as a bearer token to whoever sets an authorization header, so those are two types over one
material, each narrowing its map's `key_schema` to its own kind. Where a node type already implies
exactly one kind, no subtype is needed and the map states that kind directly.

**Carrying a `credentials` map does not by itself make a node an advertiser.** A platform type that
records how the orchestrator reaches it carries one, and it is not a credential the platform
publishes — it is how the orchestrator reaches
*them*, recorded on the node because that is what it opens. An advertiser is a node whose purpose is
to hold credential material and be bound by whoever needs it. A node can be both at once: it binds a
credential node for its own access while carrying the resolved material as configuration.

**Several credentials of one kind is requirement cardinality, not a longer map.** A map keyed by
kind holds one entry per kind by construction. A key-rotation pair, or an identity offered under two
algorithms, is expressed by binding a `count_range`-ed requirement to several credential nodes, each
contributing its own material.

**Trust material is not credential material and does not belong on this port.** What a node verifies
*others* against — a root or chain it anchors trust in — is not its own proof of identity, and
publishing it here would put two contracts on one port. It belongs on a port of its own.

**Where these would live.** The data types are in `core`. The capability type belongs
with the other capability types, which [Section 2.9 of the abstract-profile
proposal](abstract-profile-proposed-changes.md#29-communitytoscacore-and-communitytoscaabstractbase--core-as-a-standard-library)
would put in `abstract.base`. The node types belong wherever their kind belongs, which for most of them is a
technology profile rather than an abstract one — a key pair and a certificate are general, while an
account or project is a provider's.
