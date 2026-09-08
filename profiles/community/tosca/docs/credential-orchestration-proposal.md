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

**Where these would live.** The data types are in `core`, and that part is settled: an abstract
type uses `CredentialRef` as a property value, which is what Section 2.4 does in declaring
`credentials` on `Platform`. The node types belong wherever their kind belongs, which for most of
them is a technology profile rather than an abstract one — a key pair and a certificate are
general, while an account or project is a provider's.

**Where the capability type belongs is open, and is what this proposal asks the community to
settle.** The data type and the capability part company here. The data type is a value an abstract
type carries; the capability is a port that only a credential node advertises and only a consumer
binds. Nothing in `core` or the five `abstract.*` profiles declares or binds one today, and every
advertiser named above is technology-level.

- **For a technology profile.** `community.tosca.technology.base` is the base of the column every
  advertiser sits in. Putting the port in `abstract.base` places it one profile above everything
  that uses it, so a consumer of the abstract profiles imports a vocabulary nothing at that level
  touches — the same arbitrary division [Section 2.9 of the abstract-profile
  proposal](abstract-profile-proposed-changes.md#29-communitytoscacore-and-communitytoscaabstractbase--core-as-a-standard-library)
  argues against, running the other way.
- **For `abstract.base`.** An abstract type that needed to *bind* a credential node, rather than
  carry a supplied reference, would need the port visible at its level. Against that: a derived
  type may add a requirement its parent never declared, so such a binding can be introduced later
  without changing the abstract type. The §9.4 constraint that makes the container-platform
  credential vocabulary urgent — a refinement narrows and cannot widen — governs a `key_schema` the
  parent already declares, not a requirement it never did.

The two answers also differ in what else they wait on. A technology profile settles the question on
its own; `abstract.base` makes it wait on Section 2.9, which decides where the base capability types
live.

---

## A worked example — an orchestrated certificate

A certificate is the clearest case of the distinction this proposal turns on. It cannot be supplied
as a value, because it does not exist before deployment: issuing one means generating a key pair,
building a signing request and obtaining a signature, and the material that comes back is renewed,
revoked and access-controlled for as long as the node lives. That is a lifecycle, and in TOSCA a
thing with a lifecycle is a node.

The type below is trimmed to what the proposal is about; a production definition carries more
properties.

```yaml
node_types:

  Certificate:
    derived_from: Root
    description: >-
      An X.509 certificate establishing the identity of a device or service.
      `Standard.create` issues one and `Standard.delete` removes it along with its
      private key. The issued certificate's metadata is written to the attributes
      below, and the material is published on the `credential` port.
    properties:
      common_name:
        type: string
        description: >-
          Subject common name: the identity the certificate asserts.
      subject_alt_names:
        type: list
        entry_schema: string
        required: false
        description: >-
          Subject alternative names applied to the issued certificate. A client
          matches these against the address it dialled, so a certificate presented
          by a server needs at least one.
      usage:
        type: list
        entry_schema: string
        default: [client]
        description: >-
          What the certificate may be used for, as a set, since one certificate can
          serve several roles.
      validity_days:
        type: integer
        default: 365
        description: >-
          Requested certificate lifetime, in days.
    attributes:
      certificate:
        type: string
        description: >-
          The public certificate as base64-encoded PEM, carried in the model so a
          relying party can present it directly. Populated by `create`. The private
          key never leaves the host that generated it.
      not_after:
        type: string
        description: >-
          Expiry timestamp, so a renewal can be driven from the model.
    capabilities:
      credential:
        type: Credential
        properties:
          credentials:
            key_schema:
              validation: {$valid_values: [$value, [x509_cert, x509_key]]}
      # The chain a relying party verifies this certificate against is not this
      # node's proof of identity, so it is published on a port of its own rather
      # than here.
    requirements:
      # The issuing authority. Unbound, `create` self-signs and the leaf is its own
      # anchor; bound, the certificate is issued by that authority.
      - ca:
          capability: Certification
          count_range: [0, 1]
```

**No value is assigned to the map, and that is the point.** `credentials` is declared as a property
so that one declaration yields both views, but nothing is assigned here: `create` writes the
reflected attribute along the path a consumer reads,
`[SELF, CAPABILITY, credential, credentials, x509_cert, file]`. A supplied credential would assign
the same map under `capabilities.credential.properties` instead. The consumer reads it the same way
in both cases and never learns which origin it was.

**Two kinds, one node, no subtypes.** The `key_schema` narrows the map to `x509_cert` and
`x509_key`, which are the two parts of one identity rather than two ways of using the same material
— a certificate and the private key that proves it. They are separate roles, one each, so they
occupy separate keys without collision, and there is nothing for a binding to choose between. That
is the case the proposal contrasts with material that serves two kinds at once, where only the node
type is known early enough to constrain the binding and a subtype per kind is what settles it.

**The self-signed case needs no conditionality.** `ca` is `count_range: [0, 1]`. Unbound, `create`
self-signs and the leaf is its own anchor; bound, the certificate is issued by that authority. A
relying party binds the same way in either case and never learns which it was, so no property
records the distinction and no expression tests it.

**A consumer binds the port, not the type.** A node needing an identity declares
`capability: Credential` and takes whatever satisfies it, which is what makes the port a contract:
the same requirement is served by a certificate here and by some other credential node elsewhere,
with no change to the consumer. It pins `node: Certificate` only when it specifically needs a
certificate and not merely a credential.
