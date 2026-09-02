# Proposed Enhancements to the TOSCA Community Abstract Profiles

**Status:** Discussion draft. Sections 2.3, 2.7 and 2.8 and Problems 5–7 were added between
August and September 2026 and have not been discussed; the rest carry the outcomes of the
2026-06-24 community meeting. Each proposal in Section 2 states its own status.
**Audience:** TOSCA Community
**Purpose:** Capture a concrete set of proposed enhancements to the community
abstract profiles, together with the problems uncovered while prototyping them
and the decisions reached during community discussion.

**Related documents:** [README](../README.md) · [prior-art](prior-art.md) · [design-guide](design-guide.md) · [meeting-history](../../../../governance/meeting-history.md) · [decision-log](../../../../governance/decision-log.md) · [open-issues](../../../../governance/open-issues.md)

**How this document is organized.** Four parts, which cross-reference each other by number.
**Section 1** says why these changes are being proposed. **Section 2** is the proposals
themselves, grouped by profile in the order the profiles build on each other, each carrying
its own status. Two profiles have more than one proposal. **Section 3** is the reasoning: the
problems found while prototyping, numbered *Problem 1* through *Problem 7*, and most Section 2
proposals point at the problem that motivates them. **Section 4** records what the community has
settled and what is still open, numbered *question 1* through *question 9* — so a reference to
"question 2" anywhere above means the second entry there.

---

## 1. Background and motivation

The community abstract profiles — `community.tosca.core` and the five
`community.tosca.abstract.*` profiles (`base`, `platform`, `data`, `application`,
`network`) — define most of their node types as essentially *description-only*: they carry a
`derived_from` and a description, but few or no properties and requirements. All six platform
types declare no properties at all.

Ubicity maintains a set of **extension profiles** (`com.ubicity.abstract.platform`,
`com.ubicity.abstract.data`, `com.ubicity.abstract.network`, and an empty
`com.ubicity.abstract.application`) whose only purpose is to derive from the community types
and add the properties and requirements needed to actually use them: management address,
credentials, hosting requirements, a concrete `RelationalDatabase`, a network's address range.
Where Section 3 discusses a property such as `mgmt-address` or `credentials`, it is describing
these extension profiles — the community types themselves declare neither.

The goal of this proposal is to **fold those features into the community
profiles**, so the extension profiles are no longer necessary and downstream
templates can rely on the community types directly. Prototyping this exposed
several issues — documented in Section 3 — that should be settled by the
community first.

Two sections run in the opposite direction. `community.tosca.abstract.application` is not
description-only: `SingleHostApplication` carries a property and a name that assert more than
the model holds, so Section 2.7 **removes** rather than adds — the reasoning is in Problem 4.
Section 2.6 also removes, taking the interaction declarations off the two concrete application
types and the same-type constraint with them.

---

## 2. Proposed changes

### 2.1 `community.tosca.core` — add `CredentialRef` and `NamedCredentialRef`

**Status: open.** Supersedes the credential model recorded in Sections 2.4 and 2.5.

A credential in a model is a **reference** to material, never the material. The value carries
the path to the file holding it and an identifier where one is needed; the material is read on
the host where it is used and never enters the representation graph. Properties and attributes
are visible in deployed-model state and inputs files are routinely committed, so a value placed
there leaks.

```yaml
data_types:
  CredentialRef:
    description: >-
      A reference to credential material: the path to the file holding it, and an
      identifier where one is needed.
    properties:
      name:
        type: string
        required: false
        description: >-
          Populated where the material needs an identifier -- the principal to
          authenticate as, or the entry to select inside a file that holds
          several, where leaving it unset selects the file's own default.
      file:
        type: string
        required: true
        description: >-
          Path to the file holding the material, read on the host where the
          credential is used.

  NamedCredentialRef:
    description: >-
      A CredentialRef that authenticates as someone, so it always names the
      principal.
    derived_from: CredentialRef
    properties:
      name:
        type: string
        required: true
```

**What kind of credential a value is does not live in the value.** It comes from the context the
value sits in — the key of the map holding it, or the type of the node advertising it. A consumer
that must tell an SSH key from a bearer token therefore reads a map keyed by kind rather than a
bare property, which supplies no kind at all:

```yaml
    credentials:
      type: map
      key_schema:
        type: string
        validation: { $valid_values: [ $value, [ ssh_key, ssh_password ] ] }
      entry_schema:
        type: NamedCredentialRef
      required: false
```

**Why this belongs in `core` rather than in each profile.** TOSCA typing is nominal: two
two types with identical fields are not compatible, so a node declaring its own credential type can
never substitute for one declaring another's, however alike the fields. Today
`org.opengroup.opas` declares a flat `Credential` of its own — `UserName`, `KeyFile`,
`PasswordFile`, mirroring the O-PAS Part 9 schema — and a bridge translating between it and a
Ubicity credentials map must disassemble and reassemble the value field by field. With both
importing one declaration from `core`, that translation disappears. Shared declaration is the
only thing that produces it; identical fields do not.

It also settles a question that otherwise has no good answer. Converting a standards-derived
profile in place means deviating from the standard it exists to represent. Adopting a type from
a community profile *below* it is not a deviation — it is the layering working.

**This does not reopen [question 2](#question-2--credential-typing).** That question settles which *type each node uses* for its
credential, and resolved it as specific to the technology being authenticated to. This section
settles where the reference types are *declared*, so that two profiles naming the same one are
nominally compatible. A profile is free to type a credential property as a `string` under
[question 2](#question-2--credential-typing)'s resolution and still import these; `RelationalDatabase` in Section 2.5 does exactly
that.

> Note: an earlier draft of this section proposed a flat `Credential` carrying `user_name`,
> `key_file` and `password_file`, mirroring what `com.ubicity.core` declared at the time. That
> definition has since been superseded there by the two types above, and the flat one is retained
> only for compatibility until a major version removes it. It is not proposed here.

### 2.2 `community.tosca.abstract.base` — `name` on `Base`

**Status: adopted.** `Base` declares `name` and `Application` no longer duplicates it. Kept
here as the record of what was agreed and why.

Move `name` up to the common `Base` node type so every node (Platform, Data,
Network, Application) inherits it, and remove the duplicate declaration from
`Application`:

```yaml
node_types:
  Base:
    properties:
      name:
        type: string        # required
      technology: { ... }
      product: { ... }
      implementation-details: { ... }
```

### 2.3 `community.tosca.abstract.base` — one containment relationship, one requirement name

**Status: open, not yet discussed.** Reasoning in Problems 5 and 6.

Deployment layering is a single concept, so it should have a single relationship type and a
single requirement name, declared once on `Base`, with the *capability* saying what kind of
thing is being placed.

This is the [Component/Port pattern](design-guide.md#componentport-pattern) applied to
deployment. The capability is the port, and names the functionality a node exposes — *I can
host a platform*, *I can provide an execution environment*, *I can hold data*. The relationship
names the intent of the source toward that port. Three relationship types that differ only in
which capability each accepts are stating on the relationship something the port already
states — which is the argument Problem 6 makes at length.

**One relationship type.** `HostedOn`, `RunsOn` and `AvailableOn` are identical but for the
capability each accepts — same parent, same `implementation-details` property, and all three
carry `metadata: {relationship_kind: containment}`, so the profile already declares them to be
one kind. Let `HostedOn` accept all three capabilities:

```yaml
relationship_types:
  HostedOn:
    metadata:
      relationship_kind: containment
    derived_from: ContainedBy
    properties:
      implementation-details: { type: YAML, required: false }
    valid_capability_types: [ PlatformHost, ExecutionEnvironment, DataPlatform ]

capability_types:
  PlatformHost:         { derived_from: Container, valid_relationship_types: [ HostedOn ] }
  ExecutionEnvironment: { derived_from: Container, valid_relationship_types: [ HostedOn ] }
  DataPlatform:         { derived_from: Container, valid_relationship_types: [ HostedOn ] }
```

**One requirement name, declared once on `Base`.** `host` is the name TOSCA has used for
deployment layering throughout its history; `runs-on` and `available-on` are new names for
that established concept. Every one of `Base`'s children needs it — `Platform` onto a
platform, `Application` onto an execution environment, `Data` onto a data platform, and
`Network` onto a virtualization platform (which a downstream extension already adds) — so
declare it on `Base` and let each child refine the capability:

```yaml
node_types:
  Base:
    requirements:
      - host:
          capability: Container      # the common parent of the three below
          relationship: HostedOn
          # count_range defaults to [0, UNBOUNDED]; children narrow it

  Platform:
    requirements:
      - host:         { capability: PlatformHost }
      - control-host: { capability: ExecutionEnvironment, relationship: HostedOn }
      - links-to:     { capability: Linkable,             relationship: LinksTo }

  Application:
    requirements:
      - host:      { capability: ExecutionEnvironment }
      - processes: { capability: DataSource, relationship: Processes }

  Data:
    requirements:
      - host: { capability: DataPlatform }

  Network:
    requirements:
      - host: { capability: PlatformHost, count_range: [ 0, 1 ] }
```

The refinement rules permit this exactly (§8.4.1): a refined `capability` must derive from the
parent's, and `PlatformHost`, `ExecutionEnvironment` and `DataPlatform` all derive from
`Container`; a refined `relationship` must derive from the parent's, and all use `HostedOn`; a
refined `count_range` must lie within the parent's, which `[0, UNBOUNDED]` accommodates. `Base`
must name the capability *type* rather than a symbolic capability name, since the rules forbid
refining a symbolic one — `Container` is a type, so this holds.

Declaring it on `Base` says something worth saying at that level: **everything in this model
can be deployed onto something, and its kind determines onto what.** It also makes the
deployment hierarchy uniformly traversable — *what is this deployed on?* is answerable for any
node without first establishing its kind, which is what placement against an inventory needs.

**And a second name for the control plane.** `Platform` is the one type needing two placements
— its data plane and its control plane — and they cannot share a name, since names are unique
within a type. Declaring one `host` with an unbounded `count_range` and distinguishing the
assignments by `capability` is legal grammar but not usable: a TOSCA path selects a
requirement by name and index, never by capability, so a realization could not tell which
bindings are which. Hence `control-host`, reading with `host` as the pair it is — *where my
data plane is hosted*, *where my control plane is hosted*.

`control-host` is a placeholder for whatever the community prefers, provided it is
relation-shaped like its neighbours rather than naming a thing.

**On `Platform`, and not on `Base`.** The two requirements sit at different levels on purpose.
`host` belongs on `Base` because everything in this model is deployed somewhere and only the
kind of target varies. `control-host` belongs on `Platform` because only some things deploy a
control plane apart from what it controls. The test is whether an abstraction presents as one
thing to its consumers while deploying in two places:

| type | needs it | |
|---|---|---|
| `Platform` | yes | Kubevirt's operator on a cluster with KVM on a server; a cluster's control node against its workers |
| `Network` | eventually | an SDN separates a controller from its forwarding elements while presenting as one network to whatever links to it. Nothing models such a network today, so `Network` declares its own if the case arrives |
| `Data` | no | a dataset has no control plane. What resembles one belongs to the platform hosting the data, and the model already separates those |
| `Application` | no | where an application has a control component deployed elsewhere, the model's answer is to decompose it into nodes related through `InteractsWith` |

The `Application` row is a reason not to hoist this to `Base`, not merely a reason not to
bother. A second placement on `Application` would offer an alternative to decomposing, letting
an author hide a multi-component application inside a single node — which is the modelling the
horizontal decomposition into Application, Data, Platform and Network exists to prevent.

**Migration.** There is no soft path, because **TOSCA has no aliasing mechanism**. The only
`alias` in the specification is the YAML anchor convenience in `dsl_definitions`; nothing lets
one type stand for another, or one requirement name stand for another, and `deprecated` is not
a keyname.

Retaining `RunsOn` and `AvailableOn` as declared types would not help. They and `HostedOn`
derive from `ContainedBy` as siblings, so a requirement declared against one is not satisfied
by a relationship of the other — refinement requires derivation, and siblings do not derive.
For the same reason `host` and `runs-on` declared together on one type are two requirements,
not one requirement under two names: an author could bind both, and a realization expecting
one would not see the other.

So this is a breaking change, and the mechanism for it is profile versioning. That is cheaper
here than it sounds: **no version of these profiles has ever been released** — the repository
carries no tags — so there is no published artifact to stay compatible with. The consumers that
exist import `community.tosca.abstract.base:0.1` by name-version string against a moving
`master`, which is the coupling [Question 3](#question-3--single-source-of-truth-for-shared-types)
describes and proposes to resolve as one coordinated cut. This change belongs in that cut.

**Whether a control node also hosts workloads is a separate question**, and it belongs to the
platform profile rather than to this proposal: it is about how a multi-node cluster is modelled,
not about how many relationship types the base profile needs. It is asked and answered in
[the platform profile's README](../abstract/platform/README.md#does-a-control-node-also-host-workloads).
Declaring `control-host` is a prerequisite for either answer, which is why it is mentioned here
at all.

### 2.4 `community.tosca.abstract.platform` — properties and requirements

**Status: open.** The six community platform types declare no properties today.

`credentials` is declared once on `Platform` in the shape Section 2.1 gives it. What each
platform type adds is the **vocabulary of credential kinds it accepts**, as a `key_schema`
refinement — §9.4 permits refining a `key_schema`, and a refinement's validation clause is
considered *in addition to* the parent's, so a derived type narrows and cannot widen.

| Node type | Added properties | Added requirements |
|-----------|------------------|--------------------|
| `ServerPlatform` | `mgmt-address: IPv4Socket` (opt), `credentials` keyed `[ssh_key, ssh_password]` | `host` — inherited from `Platform` — refined to `node: VirtualizationPlatform` |
| `VirtualizationPlatform` | `mgmt-address: string` (opt), `credentials` keyed `[token, cloud_account]` | the control-plane requirement — see Section 2.3, which declares it on `Platform` under a name of its own |
| `ContainerPlatform` | `credentials` keyed `[kubeconfig]` | — |

`PaasPlatform`, `SaasPlatform` and `ServerlessPlatform` are not addressed. Nothing has been
prototyped against them, so there is no evidence yet for what they would need.

### 2.5 `community.tosca.abstract.data` — `RelationalDatabase`

**Status: open.**

```yaml
node_types:
  RelationalDatabase:
    description: >-
      Represents a relational database — a set of at-rest data managed by a
      relational database management system.
    derived_from: AtRestData
    properties:
      credential:
        type: NamedCredentialRef        # Section 2.1
        required: false
```

A database is authenticated to one way, so a single property is the right declaration here
rather than the map keyed by credential kind that Section 2.4 gives the platform types — there
is only one kind, and nothing for a key to distinguish. It is a `NamedCredentialRef` because a
database login names the principal it authenticates as.
[Question 2](#question-2--credential-typing)'s resolution admits either declaration.

### 2.6 `community.tosca.abstract.application` — one interaction port, specialized per kind

**Status: open, not yet discussed.** Reasoning in Problem 7.

An application should be able to expose functionality to other applications, and today only two
concrete types can. Give `Application` a property-free port that derived profiles specialize,
rather than hoisting the network-specific one that exists. Reasoning in Problem 7.

**A base capability, with `Endpoint` as its network specialization.** `Endpoint` carries `port`,
`target-port` and `protocol` — the right contract for a network endpoint and the wrong one to
oblige every application to honour. It is a specialization that was never given its base:

```yaml
capability_types:
  Service:
    description: >-
      Advertizes the ability to provide a service to other components. Derived
      types carry the contract a consumer reads to use it.
    derived_from: Partner          # community.tosca.core, targeted by AssociatesWith

  Endpoint:
    description: >-
      A service reached over a network.
    derived_from: Service
    properties:
      port:        { type: Port }
      target-port: { type: Port }
      name:        { type: string, required: false }
      protocol:    { type: string, required: false }
```

`Service` names the functionality exposed, in the same construction as `DataSource` — the
ability to make data available. `Interaction` would name the relationship rather than the
functionality, against the naming principle in the design guide, and `Interface` collides with
TOSCA's own `interface_types`.

**Declared on `Application`, at both ends.** Interaction is symmetric between applications, so
the abstract type carries the capability and the requirement, as `Platform` already does for
`host`:

```yaml
node_types:
  Application:
    capabilities:
      service:
        type: Service
    requirements:
      - interacts-with:
          capability: Service
          relationship: InteractsWith
      - processes:
          capability: DataSource
          relationship: Processes
      - host:
          capability: ExecutionEnvironment
```

The two names follow the split the design guide draws: the **capability** names the functionality
exposed, so `service`; the **requirement** names the intent of the source toward the target, so
`interacts-with`, reading like `links-to` and `processes` beside it. The existing `endpoint`
requirement is the profile's one requirement named for a thing rather than a relation.

**The concrete types shed their local declarations** and refine only where they differ:

```yaml
  MicroService:
    derived_from: Application
    capabilities:
      service: { type: Endpoint }        # refinement: Endpoint derives from Service

  SingleHostApplication:               # ServerApplication, if Section 2.7 is adopted first
    derived_from: Application
    capabilities:
      service: { type: Endpoint }
```

Both lose their `endpoint` capability and requirement. The same-type pinning goes with them:
neither `node: MicroService` nor `node: SingleHostApplication` survives, so an application may
interact with an application of another type — which is the ordinary case, and what O-PAS needs
for signals flowing from an I/O channel configuration to a control logic deployment. A profile
that does want to constrain the sources states them on the capability with
`valid_source_node_types`, as O-PAS already does.

**`InteractsWith` rederives from the association kind.**

```yaml
relationship_types:
  InteractsWith:
    metadata:
      relationship_kind: association
    derived_from: AssociatesWith       # community.tosca.core, was DependsOn
    valid_capability_types: [ Service ]
```

A dependency asserts that the target must exist first. Interaction between applications does not
always carry that order, and control signals are the case where it must not: an I/O channel and
the logic reading it are commissioned independently. Where an interaction *is* ordering-bearing,
a profile derives a dependency-kind relationship of its own.

**The refinement rules permit all of this.** A refined capability's `type` must derive from the
parent's (§8.2.1), and `Endpoint` derives from `Service`. A refined requirement's `capability`
and `relationship` must likewise derive from the parent's (§8.4.1), which is what lets a derived
profile narrow `interacts-with` onto a specialized port — O-PAS deriving `SignalSource` from
`Service`, adding `Tags`, and `ReceivesSignalFrom` from `InteractsWith`.

**Why `Application` keeps both `processes` and `interacts-with`.** Section 2.3 argues that
requirements differing only in which capability they accept should collapse into one, and today
these two would qualify: `processes` reaches a `DataSource` and `interacts-with` reaches an
`Endpoint`, both over a relationship derived from `DependsOn`, both `relationship_kind:
dependency`. By that test one requirement seeking a `Feature` would do.

Rederiving `InteractsWith` from `AssociatesWith` is what separates them. `processes` stays a
**dependency** — the dataset exists before the application that processes it, and deployment
order follows — while `interacts-with` becomes an **association**, asserting no order. Section
2.3 collapses three relationships that were all `relationship_kind: containment`; the same test
keeps these two apart, because their kinds differ.

They also reach different kinds of entity: `processes` reaches `Data`, `interacts-with` reaches
`Application`. Collapsing them would make *what does this application consume* answerable only
by inspecting capability types rather than by traversal, which is what the horizontal
decomposition exists to avoid.

**Independent of Section 2.3.** The placement requirement is shown as `host`, the name that
section proposes; read it as `runs-on` otherwise. Nothing here depends on which — `service`,
`interacts-with` and `processes` are all dependency- or association-kind, and neither proposal
touches the other's names.

**Migration.** The capability and requirement both change symbolic name, from `endpoint` to
`service` and `interacts-with`. Templates assigning the capability, and TOSCA paths reading its
contract through a `CAPABILITY` step, must be updated. TOSCA has no aliasing of any kind, so
neither this change nor Section 2.3's can be softened — both are breaking changes that belong
in the coordinated cut described in
[Question 3](#question-3--single-source-of-truth-for-shared-types). The break here is small and
worth taking now: nothing has been released, and `MicroService` and `SingleHostApplication` are
the only types that declare either name.

---

### 2.7 `community.tosca.abstract.application` — name the platform, drop the processes

**Status: open.** Reasoning in Problem 4.

Rework `SingleHostApplication` so that what it asserts is what it holds. The reasoning
is in Problem 4.

```yaml
node_types:
  ServerApplication:
    description: >-
      An application that runs on a server platform.
    derived_from: Application
    capabilities:
      service: { type: Endpoint }        # Section 2.6
    requirements:
      - host:
          capability: ExecutionEnvironment
          node: ServerPlatform           # Section 2.3
```

The type declares only two refinements, because Section 2.6 puts the interaction port on
`Application` and Section 2.3 puts the placement requirement on `Base`. Read `host` as
`runs-on` if Section 2.3 is not adopted; this proposal is about the type's name and its
`processes` property and does not depend on either.

Three changes from the current type:

- **Named for the platform it targets**, consistent with `MicroServiceApplication` and
  `ServerlessApplication`, rather than for a cardinality.
- **`processes` removed.**
- **Cardinality expressed as `count_range` on the placement requirement** — in the type where a kind of
  application genuinely constrains it, in the template where it does not.

The last of these unifies a mechanism rather than adding one. An application spanning
several servers becomes `host` bound several times, which is the same form the platform
profile already uses for a cluster spanning several servers. One way to say "how many",
at both layers, instead of a type per cardinality.

Section 2.6 is what removes the `endpoint` capability and requirement this type declares
today. The two proposals are otherwise independent and can be adopted in either order.

### 2.8 `community.tosca.abstract.network` — what a network is addressed as, and whether it reaches the internet

**Status: open, not yet discussed.** No corresponding problem section: the two properties are additions every realization written against `Network` has needed, not a defect in the community types.

`community.tosca.abstract.network` declares no types; `Network` in `abstract.base` carries only
what `Base` gives it and a `linkable` capability. Two properties are wanted by every realization
that has been written against it:

```yaml
node_types:
  Network:
    properties:
      cidr_block:
        description: >-
          Address range of this network, in CIDR notation. Left unset for a
          forwarding domain that carries no addressing of its own, or one whose
          range the realization assigns.
        type: string
        required: false
      internet_accessible:
        description: >-
          Whether traffic on this network reaches the public internet. A network
          that does not say so does not.
        type: boolean
        default: false
```

**`cidr_block` is what a network is addressed as**, and every realization needs it: an AWS VPC
and subnet, an OpenStack Neutron network and subnet, a Proxmox bridge. It is optional because a
forwarding domain need not carry addressing of its own, and because a realization may assign the
range rather than receive it.

**`internet_accessible` is a selector, not a description.** It states an intent the realization
must satisfy — on AWS the difference between attaching an internet gateway and a route to it or
leaving the subnet isolated — and a substitution filter reads it to choose between the reachable
and isolated realizations of the same abstract network. Defaulting to `false` makes the safe
case the one an author gets without asking for it.

Both are declared today in a downstream extension, alongside the `host` requirement onto a
virtualization platform that Section 2.3 notes in passing. The requirement is proposed there;
these two properties are what remains.

---

## 3. Problems and open issues

These were the proposed changes **as ported directly from the Ubicity
extension profiles**. Doing so surfaced the following problems, which are the
real reason this is a discussion document rather than a pull request.

### Problem 1 — Inconsistent typing of `mgmt-address` (`string` vs `IPv4Socket`)

**Resolved — see [Question 1](#question-1--mgmt-address-typing).** The properties discussed here are the extension profiles',
not the community types': the community platform types declare none.

The same conceptual property is typed differently depending on the node:

- `ServerPlatform.mgmt-address` → `IPv4Socket` (the structured address+port
  complex type)
- `VirtualizationPlatform.mgmt-address` → `string`

**Why the inconsistency exists.** This is not arbitrary — the address shape
tracks *how the platform is reached*:

| Node type | How it is reached | Example (from the Ubicity profiles) | Type |
|-----------|-------------------|--------------------------------------|------|
| `ServerPlatform` | a host contacted at an IP address and port (e.g. SSH on port 22) | the `Compute` `endpoint` `address` (`ip_address` + `port`) | `IPv4Socket` |
| `VirtualizationPlatform` | a service/control-plane API identified by a URL | Proxmox `url` (`https://<host>:8006/...`); a cloud region endpoint | `string` |

A server is contacted at a concrete network socket, which has a well-defined
structure (address + port). A virtualization / API platform is contacted via a
**URL** (scheme, host, optional port, path) that `IPv4Socket` cannot represent —
so it falls back to an opaque `string`.

So the real question is not merely "pick one type," but how to model these two
connection paradigms: a single management-endpoint type that generalizes both
(a URI-like type for socket and URL), versus distinct, explicitly named
properties per derived platform type.

**Discussion outcome (TOSCA Community meeting, 2026-06-24).** Rather than force
a single, one-size-fits-all `mgmt-address` onto the base `Platform` node type,
the community agreed to keep the management-address **property name and type
specific to each derived platform type**. A `ServerPlatform` is reached at a
network socket and uses a structured socket type; an API-style platform
(virtualization / container) is reached at a URL and uses a `string` — or, where
more structure is warranted, a `JSON` object with a platform-specific format.
Constraining this on the base type was considered and rejected as too rigid for
the range of platforms involved.

### Problem 2 — Inconsistent typing of `credential` (`string` vs `Credential`)

**Resolved — see [Question 2](#question-2--credential-typing).** As with Problem 1, these are the extension profiles'
properties. They have since been reshaped into a map keyed by credential kind, so the singular
`credential` typed `Credential` described below no longer exists anywhere; Section 2.1 carries
the current model. The resolution still holds — what a credential is typed as remains specific
to what is being authenticated to.

Likewise, `credential` is typed inconsistently:

- `ServerPlatform.credential` → `Credential`
- `VirtualizationPlatform.credential`, `ContainerPlatform.credential`,
  `RelationalDatabase.credential` → `string`

**Why the inconsistency exists.** As with the address, the credential shape
tracks the *authentication model of the underlying technology*:

| Node type | Example technologies | Credential in practice | Type |
|-----------|----------------------|------------------------|------|
| `ServerPlatform` | physical / SSH-accessible host | a login identity: user name **plus** a key file or password | structured `Credential` (`user_name`, `key_file`, `password_file`) — consumed as the `Compute` `sudo_user` |
| `ContainerPlatform` | Kubernetes — k3s, k0s, kubeadm, microk8s, minikube | a **kubeconfig** file | `string` (file path / blob) |
| `VirtualizationPlatform` | AWS | an AWS **credentials file** | `string` (`credentials_file`) |
| `VirtualizationPlatform` | Proxmox | an **API token file** | `string` (`api_token_file`) |

A host you *log into* has a well-defined, multi-field identity (a user plus a
secret), so a structured `Credential` fits naturally. A control-plane / API you
*authenticate to* uses a single, opaque, technology-specific artifact — a
kubeconfig, an AWS credentials file, a Proxmox API token — that shares no common
structure across technologies, so it is carried as a bare `string` (typically a
path to the artifact).

So this is the same modeling tension as Problem 1: the mix is not simply
sloppiness, it reflects two real authentication paradigms (a structured login
vs. an opaque token/config artifact).

**Discussion outcome (TOSCA Community meeting, 2026-06-24).** As with the
management address, the community agreed **not** to harmonize `credential` on
the base `Platform` node type, and instead to let each derived platform type
declare the credential property name and type that fits its authentication
model: a structured `Credential` for login-based servers, and a `string` (or a
`JSON` object with a platform-specific format) for the opaque token/config
artifacts used by cloud and cluster platforms (kubeconfig, AWS credentials file,
Proxmox API token). A single abstract base credential property was considered
and rejected in favor of platform-specific properties.

### Problem 3 — No formal release process for the community profiles

> **Update (2026-08-23): release automation now exists. Most of this section
> describes the situation before PR #350.** `.github/workflows/release.yml` and
> `tools/scripts/build_csars.sh` build a CSAR per `community.tosca.*` profile
> (discovered by `TOSCA.meta`, named from the profile name-version, so
> `community.tosca.core:0.1` becomes `community.tosca.core.0.1.csar`), sign every
> artifact with Sigstore keyless signing, publish a signed SHA256 checksum
> manifest, and open a **draft** GitHub Release for review. It fires on a pushed
> semver tag (`v0.1`, `v0.1.0`, and rc variants) or by manual dispatch, and the
> repository is public, so release-asset URLs need no authentication.
>
> **What remains true:** no tag has been pushed yet, so **no release has been
> cut** — the mechanism is built and unfired. Versioning/governance documentation
> is still owed, and one concrete gap sits inside it: CSAR names derive from the
> **profile name-version string inside each profile**, not from the git tag, so
> freezing a version and opening the next one means bumping those strings as a
> deliberate step.
>
> **This changes the conclusion below.** A signed, checksummed CSAR *is* the
> immutable artifact whose absence is given here as the reason an external
> ecosystem cannot depend on the community core types. Once `0.1` is tagged, a
> consumer can pin to a release instead of to a moving `master`. See [Question 3](#question-3--single-source-of-truth-for-shared-types).

The situation this section was written against:

- no git tags and no published releases,
- ~~no release automation~~ — **shipped in PR #350 (July 2026)**,
- no versioning/governance documentation beyond `CONTRIBUTING.md`,
- a pure fork-and-pull-to-`master` workflow.

The profile-name version (e.g. `community.tosca.core:0.1`) is a static string,
not a released, immutable artifact.

This makes **any profile that imports the community profiles brittle**: a
consumer effectively pins to a moving `master`, so an upstream edit can silently
change or break dependent profiles with no versioned artifact to pin to and no
deprecation path. It is the main reason an external ecosystem (such as Ubicity)
cannot safely take a hard dependency on the community core types — for example,
having downstream profiles converge on the community `Credential` / `IPv4Socket`
definitions instead of maintaining their own (see [Question 3](#question-3--single-source-of-truth-for-shared-types) below).

A well-defined release process (immutable, versioned, tagged releases with a
documented compatibility/deprecation policy) is a prerequisite for the
community abstract profiles to serve as a shared foundation that other profiles
can depend on.

**Discussion outcome (TOSCA Community meeting, 2026-06-24).** The community
agreed this is a real risk worth addressing. Near term, the current `0.1`
version is kept as-is; once `0.1` is considered stable it will be **frozen**,
and subsequent changes will go into a new version. The community will begin
planning version tracking and a formal release process that publishes immutable
release artifacts — building CSAR files as release artifacts (mirroring
Ubicity's existing onboarding workflow) was raised as one candidate mechanism,
to be refined.

### Problem 4 — `SingleHostApplication` names a constraint it does not impose

Three distinct issues sit in one type, found while looking for an abstract home for
software installed on a server.

**It is named for a cardinality it does not constrain.** The type declares:

```yaml
      - runs-on:
          capability: ExecutionEnvironment
          relationship: RunsOn
          node: platform:ServerPlatform
```

with no `count_range`, so it takes the `tosca_2_0` default of `[0, UNBOUNDED]` and permits
any number of hosts. "Single host" is a placement constraint, and a placement constraint is
a `count_range`, not a type. Adding a type per cardinality also does not scale: the same
reasoning would want a type for two hosts, and another for many.

**`processes` sits below the System View.** The `Process` data type is a `command` plus
`parameters`. A command string names an executable, which the
[design guide](design-guide.md) places in the Device View row — vendor-specific realization,
alongside k3s and Docker Engine. Requiring one on a System View type inverts the model
continuum the profiles are organized on.

It is also `required: true`, which makes a whole category unmodellable: software installed
on a host that runs no long-running process at all — a CLI, a client tool, a package — has
no value to supply.

**`processes` collides with an inherited requirement of the same name.** The base
`Application` declares:

```yaml
  Application:
    requirements:
      - processes:
          capability: DataSource
          relationship: Processes
```

meaning *this application processes that data*. `SingleHostApplication` then declares a
**property** named `processes` meaning *these operating-system commands*. Same name,
unrelated concepts, parent and child. This one needs fixing regardless of how the other two
are settled.

**What the type family gets right.** Three of the four application types pin `runs-on` to a
kind of platform:

| Node type | `runs-on` target |
|-----------|------------------|
| `MicroServiceApplication` | `platform:ContainerPlatform` |
| `SingleHostApplication` | `platform:ServerPlatform` |
| `ServerlessApplication` | `platform:ServerlessPlatform` |

That axis is sound System View content — what kind of platform an application needs is what
drives placement, and it mirrors the platform profile's own decomposition. So the type earns
its place in the family; it is the name and the property that do not.

Proposed replacement in Section 2.7. **Not yet discussed by the community.**

### Problem 5 — `runs-on` carries two meanings, and the platform one is not implemented

The [platform profile README](../abstract/platform/README.md) describes a second deployment
requirement on `Platform`:

> All platforms can be considered to have not only a *data plane*, but also a *control
> plane*. [...] For some platforms (such as Kubevirt), it may be necessary to model
> deployment of the control plane separately from deployment of the data plane. This is done
> by defining a second requirement in the `Platform` node type that specifies where control
> is hosted. This requirement uses the `RunsOn` relationship type rather than the `HostedOn`
> relationship type.

Two problems follow from it.

**The name is overloaded.** `Application` already declares `runs-on` — reaching an
`ExecutionEnvironment` over `RunsOn` — meaning *where this application executes*. The
platform requirement described above means something else: *where this platform's own
control plane is deployed*. Same requirement name, same relationship type, two meanings
separated only by the kind of node declaring them. Reading a template, `runs-on` tells you
nothing about which is meant until you look up the source node's type.

It is worth being precise about the platform sense, because the shorthand misleads: the
requirement does not point *at* a control-plane component. It points at the **platform that
hosts this platform's control plane**. Both ends are platforms, and both `host` and this
requirement are deployment relationships — they differ in *which plane* of the same platform
is being deployed.

**And `Platform` does not declare it.** `Platform` declares `host` and `links-to` only. The
requirement exists nowhere in the community profiles; the only implementation is a
`VirtualizationPlatform` in a downstream extension, which is the Kubevirt case the README
uses as its example.

The consequence is that the README's own multi-node Kubernetes model cannot be expressed.
That section says *"To indicate which server acts as the control node in the Kubernetes
cluster, we use the `RunsOn` relationship of the `ContainerPlatform` node"*, and describes
high availability as several such relationships — but `ContainerPlatform` inherits no such
requirement and declares none. A single-node cluster is unaffected, since control and
hosting coincide on one server; multi-node is exactly where they separate.

Proposal in Section 2.3. **Not yet discussed by the community.**

### Problem 6 — Three relationship types for one relationship kind

`HostedOn`, `RunsOn` and `AvailableOn` differ in nothing but the capability each accepts:

| | parent | properties | metadata | accepts |
|---|---|---|---|---|
| `HostedOn` | `ContainedBy` | `implementation-details` | `relationship_kind: containment` | `PlatformHost` |
| `RunsOn` | `ContainedBy` | `implementation-details` | `relationship_kind: containment` | `ExecutionEnvironment` |
| `AvailableOn` | `ContainedBy` | `implementation-details` | `relationship_kind: containment` | `DataPlatform` |

The profile labels all three `relationship_kind: containment` itself. They carry no distinct
properties, no interfaces and no behaviour — only a different `valid_capability_types`, which
duplicates what a requirement's `capability` keyname already states.

- **The design guide argues against the split.** Its naming principle holds that *capability*
  type names describe the functionality a component exposes, while *relationship* type names
  describe the intent of the source toward the target. Placing a platform, an application or
  data onto a platform is one intent against three exposed functionalities. The difference
  belongs on the capability, and it is already there.

- **`runs-on` and `available-on` are new names for an established concept.** TOSCA has used
  `host` and `HostedOn` for deployment layering throughout its history. Introducing two further
  names for the same idea obliges every reader to learn a private vocabulary for something they
  already know, and makes templates harder to move between profiles.

- **The guide also names `LinksTo` as a name to avoid**, listing it among "mechanism-flavored
  names" against which intent-revealing ones are preferred — and the base profile declares it.
  Worth settling at the same time, though it is a dependency relationship rather than a
  containment one, so it is not part of the collapse.

- **Nothing is lost by collapsing.** A `Platform` exposes all three capabilities, and a
  requirement names the capability it seeks, so which capability a relationship binds to stays
  as determined as it is today. Relationship types can carry operations, so if placing data ever
  needs different lifecycle behaviour from placing an application, a specialized type can be
  derived at that point.

Proposal in Section 2.3. **Not yet discussed by the community.**

---

### Problem 7 — `Application` cannot be interacted with, and `Endpoint` is stranded below it

Abstract `Application` declares two requirements and **no capabilities**:

```yaml
  Application:
    derived_from: Base
    requirements:
      - processes:
          capability: DataSource
          relationship: Processes
      - runs-on:
          capability: ExecutionEnvironment
          relationship: RunsOn
```

It can consume data and it can be placed, but nothing can be pointed *at* it. Every application
in the profile is a sink.

- **The pattern for application-to-application interaction exists, one level too low.** The
  `Endpoint` capability and the `InteractsWith` relationship are declared on two concrete types,
  not on the abstract one:

  | type | exposes | requires |
  |---|---|---|
  | `MicroService` | `endpoint: Endpoint` | `endpoint` → `node: MicroService` |
  | `SingleHostApplication` | `endpoint: Endpoint` | `endpoint` → `node: SingleHostApplication` |
  | `MicroServiceApplication`, `ServerlessApplication` | — | — |
  | `Application` | — | `processes`, `runs-on` |

  A profile deriving from `Application` therefore inherits no way to be interacted with, and
  must declare a capability and a relationship of its own. That is not hypothetical: the O-PAS
  (Open Process Automation) profiles declare `ControlApplicationComponent` with a `SignalSource`
  capability and a matching `Signal` requirement onto it — structurally the same as
  `Endpoint` and `InteractsWith`, a component that both publishes and consumes through a typed
  port. Two profiles, two vocabularies, one concept.

- **`Endpoint` cannot simply be promoted, because it is a network contract.** Its properties are
  `port`, `target-port`, `protocol` and `name`. That is right for a network endpoint
  and the name is honest about it — but hoisting it onto `Application` would oblige every
  application to expose a port and a protocol. An O-PAS signal port carries `Tags`; there is no
  port and no protocol to give. The design guide already prescribes the resolution: *a contract
  every realization exposes belongs on the base capability; a value specific to one realization
  belongs on a capability derived from that base.* `Endpoint` is a specialization that was never
  given its base.

- **`Endpoint` is pinned to interaction between nodes of the same type.** Its description says
  so, and both requirements name their own type as the target. Heterogeneous interaction is the
  ordinary case rather than the exception: O-PAS signals flow from an I/O channel configuration
  to a control logic deployment, two different types, stated on the capability as
  `valid_source_node_types: [IOChannelConfigurations, ControlLogicDeployment]`. The same-type
  constraint reads as an artifact of how those two concrete types were written rather than a
  property of interaction.

- **`InteractsWith` derives from `DependsOn`, when the profile's own association kind was
  available.** `community.tosca.core` defines all three kinds — `ContainedBy` over `Container`,
  `DependsOn` over `Feature`, and `AssociatesWith` over `Partner` — and `abstract.base` imports
  it. A dependency asserts that the target must exist first; an association does not. Some
  interactions carry no such order, and control signals are the clear case: an I/O channel and
  the logic reading it are commissioned independently, and a signal not yet flowing is a runtime
  condition rather than a deployment-ordering error. O-PAS derives `ReceivesSignalFrom` from
  `AssociatesWith`, which is the choice available here too. As it stands, saying two components
  exchange values also says one must be deployed before the other.

  Worth noting how the two profiles converged: O-PAS re-declares the same three base kinds under
  the same names in its own profile rather than importing `core`. Both reached for the same
  vocabulary independently. Only `InteractsWith` did not use it.

**This is not the `Application` / `Data` boundary, and treating it as one would be a mistake.**
A signal looks like data, so the tempting reading is that these components are part application
and part data, and that the horizontal decomposition fails for them. It does not. Every `Data`
subtype — `AtRestData`, `BatchData`, `StreamingData`, `EventData`, `ApiData`, `CachedData` — is
a dataset with independent existence, a lifecycle of its own, and an `available-on` requirement
onto a `DataPlatform`. A signal has none of those: nothing deploys it, and there is no data
platform it is hosted on. It is an interface a running component exposes, which is why O-PAS
models it as a capability rather than a node. The distinction that matters is not application
versus data but **data as a managed entity versus data in motion between components** — and the
profile already draws it, once as `Data` and once as `Endpoint`.

**A related gap, worth settling alongside.** Where a component genuinely does both — a historian
that runs logic *and* owns an authoritative dataset — the answer is decomposition into an
`Application` and a `Data` node joined by `processes`. But `Processes` does not distinguish
reading from writing. One relationship covers both directions, so a producer cannot be told from
a consumer, a producer cannot be ordered ahead of the consumers of what it writes, and "what
breaks if this dataset is gone" cannot be separated from "what stops being written to it".

**Proposal in Section 2.6.** It adds no base machinery: one intermediate capability, under
which both existing ports become specializations.

```
Partner                     (core, targeted by AssociatesWith)
└── Service                 declared on Application; no properties
    ├── Endpoint            + port, target-port, protocol   (network interaction)
    └── SignalSource        + Tags                          (O-PAS signals)
```

1. Declare a property-free `Service` capability on abstract `Application`, derived from
   `Partner`. It names the functionality exposed — the ability to provide a service to another
   component — in the same construction as `DataSource`, the ability to make data available.
   `Interaction` would name the relationship rather than the functionality, against the naming
   principle, and `Interface` collides with TOSCA's own `interface_types`.
2. Rederive `Endpoint` from `Service`, keeping its network properties where they belong. O-PAS
   derives `SignalSource` from `Service` and adds `Tags`.
3. Rederive `InteractsWith` from `AssociatesWith`, and drop the same-type pinning so a derived
   profile narrows permitted sources with `valid_source_node_types` as O-PAS already does.

O-PAS then harmonizes by derivation rather than parallel invention, and its own placement
modelling survives untouched: `ControlApplicationComponent` is hosted on one to four DCNs for
redundancy, which the community `runs-on` already permits, its `count_range` being unbounded by
default.

**Not yet discussed by the community.**

---

## 4. Decisions and open questions

### Question 1 — `mgmt-address` typing

*Resolved (2026-06-24):* keep the property name
and type specific to each derived platform type — a structured socket for
servers, a `string` or platform-specific `JSON` for URL-addressed API
platforms. Do not hoist a single `mgmt-address` onto the base `Platform`.

### Question 2 — `credential` typing

*Resolved (2026-06-24):* likewise platform-specific
— a structured `Credential` for login-based servers, a `string`/`JSON` for
opaque token/config artifacts. No base-level harmonization.

### Question 3 — Single source of truth for shared types

*Open, but the blocker is
gone (2026-08-23):* should `Credential`, `IPv4Socket`, etc. be owned solely by
`community.tosca.core`, with other profiles importing rather than redefining
them? The stated obstacle was that there is no immutable artifact to pin to, so
a consumer would be pinning to a moving `master`. **Release automation now
produces signed, checksummed CSARs (see Problem 3), so tagging `0.1` removes
that obstacle.** What remains is the community's decision on ownership, not a
technical impediment.

**Note that downstream consumers already carry this dependency in its unsafe
form.** The Ubicity profiles, for example, import `community.tosca.core:0.1`,
`community.tosca.abstract.data:0.1` and `community.tosca.abstract.platform:0.1`
today — by static name-version string, against a moving `master`. So cutting a
release does not create a new coupling; **it makes an existing one safe.**

**This question is now forced by N8 — the abstract-profile property work tracked in [`open-issues.md`](../../../../governance/open-issues.md) — and the two have to move together.** The
abstract platform connection properties want a structured socket for
`ServerPlatform`. A downstream profile that derives from
`community.tosca.abstract.platform:ServerPlatform` while declaring
`mgmt-address` against *its own* `IPv4Socket` hits a property-refinement type
conflict the moment N8 declares the same property upstream — the two socket
types are structurally identical but independently defined, so neither derives
from the other. That is not a soft compatibility concern; it breaks the derived
profile.

**Consequence for sequencing: N8, the `0.1` tag, and downstream convergence are
one coordinated cut, not three steps.** Land N8 against the community types, tag
`0.1`, and update downstream profiles to import the released community
`IPv4Socket` / `Credential` and drop their own copies — with the downstream
change prepared in advance so it can land immediately, leaving no interval in
which a *released* downstream profile references a half-converged type set.

### Question 4 — Release process

*Automation shipped (PR #350, July 2026); no release cut
yet.* The mechanism described in Problem 3 is in place and unfired, and the repository
still carries no tags. Remaining, per [`open-issues.md`](../../../../governance/open-issues.md)
I8: `0.1` waits on the credential model (decision D11) being present in the abstract
profiles, so that the first release carries the settled model rather than one the community
would have to revise immediately — Section 2.1 is that work. N8 can ride along. Then push
the first tag and write the versioning/governance documentation, including the rule that
profile name-version strings are bumped when a version is frozen and the next one opened,
since CSAR names derive from those strings rather than from the git tag.

### Question 5 — `SingleHostApplication`

*Open, not yet discussed.* Three questions, of
descending independence. Does the `processes` property belong at the System View at
all, given that a `command` names an executable? Should a type be named for a
cardinality it does not constrain, or should cardinality be a `count_range` on
`runs-on`? And separately from both: the property `processes` collides with the
requirement `processes` inherited from `Application`, which needs resolving on its
own terms. Proposal in Section 2.7, reasoning in Problem 4.

### Question 6 — The control-plane requirement

*Open, not yet discussed.* The platform README
describes a second deployment requirement on `Platform`, distinguishing where a platform's
control plane is deployed from where its data plane is. `Platform` does not declare it, so
the README's own multi-node Kubernetes model cannot be expressed. Declaring it also forces
the README's open question about naming, since `runs-on` already means *where this
application executes*. Proposal in Section 2.3, reasoning in Problem 5.

### Question 7 — One containment relationship, one requirement name

*Open, not yet discussed.*
`HostedOn`, `RunsOn` and `AvailableOn` are identical but for the capability each accepts,
and the profile marks all three `relationship_kind: containment`. Should they collapse into
`HostedOn`, and should `runs-on` and `available-on` collapse into `host` — the name TOSCA
has used for deployment layering throughout its history — declared once on `Base` and
refined by each child, leaving the capability to say what kind of thing is being placed? Proposal in Section 2.3, reasoning in Problem 6. Settling
this also settles [question 6](#question-6--the-control-plane-requirement), since the control-plane requirement is then a second
requirement name over the same relationship.

### Question 8 — Whether a control node also hosts workloads

*Open, not yet discussed.* **Owned by
[the platform profile's README](../abstract/platform/README.md#does-a-control-node-also-host-workloads)**,
which asks the question and sets out the two models — *set overlap*, where a schedulable
control node appears under both `host` and `control-host`, and *disjoint sets with a
property*, where `host` carries only non-control workload hosts.

It is listed here because Section 2.3 has to declare `control-host` before either model can be
written down, so the two move together. The modelling choice itself is a platform-layering
question and does not belong to this proposal.

### Question 9 — Interaction between applications

*Open, not yet discussed.* Abstract `Application`
declares no capabilities, so nothing can be pointed at it, while `Endpoint` and
`InteractsWith` sit on `MicroService` and `SingleHostApplication` — `Endpoint` carrying a
network contract that not every application can honour, and both requirements pinned to
interaction between nodes of the same type. Should a property-free `Service` capability be
declared on `Application` and derived from `Partner`, with `Endpoint` rederived from it,
should `InteractsWith` rederive from `AssociatesWith` rather than `DependsOn`, and should the
same-type constraint go? Proposal in Section 2.6, reasoning in Problem 7 — which also asks
whether `Processes` should distinguish reading a dataset from writing one.
