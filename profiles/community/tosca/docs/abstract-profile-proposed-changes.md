# Proposed Enhancements to the TOSCA Community Abstract Profiles

**Status:** Discussion draft — updated with the outcomes of the 2026-06-24
TOSCA Community meeting (pending review by Roberto)
**Audience:** TOSCA Community
**Purpose:** Capture a concrete set of proposed enhancements to the community
abstract profiles, together with the problems uncovered while prototyping them
and the decisions reached during community discussion.

**Related documents:** [README](../README.md) · [prior-art](prior-art.md) · [design-guide](design-guide.md) · [meeting-history](../../../../governance/meeting-history.md) · [decision-log](../../../../governance/decision-log.md) · [open-issues](../../../../governance/open-issues.md)

---

## 1. Background and motivation

The community abstract profiles
(`community.tosca.core`, `community.tosca.abstract.base`,
`community.tosca.abstract.platform`, `community.tosca.abstract.data`)
currently define the platform and data node types as essentially
*description-only* abstract types — they carry a `derived_from` and a
description, but few or no properties and requirements.

Ubicity maintains a small set of **extension profiles**
(`com.ubicity.abstract.platform`, `com.ubicity.abstract.data`) whose only
purpose is to derive from the community types and add the properties and
requirements needed to actually use them (management address, credentials,
hosting/runs-on requirements, a concrete `RelationalDatabase`, etc.).

The goal of this proposal is to **fold those features into the community
profiles**, so the extension profiles are no longer necessary and downstream
templates can rely on the community types directly. Prototyping this exposed
several issues — documented in Section 3 — that should be settled by the
community first.

Section 2.5 runs in the opposite direction. `community.tosca.abstract.application`
is not description-only: `SingleHostApplication` carries a property and a name that
assert more than the model holds, so the proposal there **removes** rather than adds.
It came out of the same prototyping — looking for an abstract type to describe software
installed on a server — and the reasoning is in Problem 4.

---

## 2. Proposed changes

### 2.1 `community.tosca.core` — add a `Credential` data type

A complex `Credential` data type used to describe authorization credentials for
network-accessible resources:

```yaml
data_types:
  Credential:
    description: >-
      The Credential type describes authorization credentials used to
      access network-accessible resources.
    properties:
      user_name:
        type: string
        required: true
      key_file:
        type: string
        required: false
      password_file:
        type: string
        required: false
```

> Note: this mirrors the existing Ubicity `com.ubicity.core` `Credential`
> definition. The exact shape (field names, optionality, additional fields such
> as protocol or token type) is open for discussion.

### 2.2 `community.tosca.abstract.base` — `name` on `Base`

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

### 2.3 `community.tosca.abstract.platform` — properties and requirements

| Node type | Added properties | Added requirements |
|-----------|------------------|--------------------|
| `ServerPlatform` | `mgmt-address: IPv4Socket` (opt), `credential: Credential` (opt) | `host` refined to `node: VirtualizationPlatform` |
| `VirtualizationPlatform` | `mgmt-address: string` (opt), `credential: string` (opt) | the control-plane requirement — see 2.6, which declares it on `Platform` under a name of its own |
| `ContainerPlatform` | `credential: string` (opt) | — |

### 2.4 `community.tosca.abstract.data` — `RelationalDatabase`

```yaml
node_types:
  RelationalDatabase:
    description: >-
      Represents a relational database — a set of at-rest data managed by a
      relational database management system.
    derived_from: AtRestData
    properties:
      credential:
        type: string
        required: false
```

### 2.5 `community.tosca.abstract.application` — name the platform, drop the processes

Rework `SingleHostApplication` so that what it asserts is what it holds. The reasoning
is in Problem 4.

```yaml
node_types:
  ServerApplication:
    description: >-
      An application that runs on a server platform.
    derived_from: Application
    capabilities:
      endpoint:
        type: Endpoint
    requirements:
      - endpoint:
          node: ServerApplication
          capability: Endpoint
          relationship: InteractsWith
      - runs-on:
          capability: ExecutionEnvironment
          relationship: RunsOn
          node: ServerPlatform
```

Three changes from the current type:

- **Named for the platform it targets**, consistent with `MicroServiceApplication` and
  `ServerlessApplication`, rather than for a cardinality.
- **`processes` removed.**
- **Cardinality expressed as `count_range` on `runs-on`** — in the type where a kind of
  application genuinely constrains it, in the template where it does not.

The last of these unifies a mechanism rather than adding one. An application spanning
several servers becomes `runs-on` bound several times, which is the same shape the platform
profile already uses for a cluster spanning several servers. One way to say "how many",
at both layers, instead of a type per cardinality.

`endpoint` and its `InteractsWith` requirement are declared identically on `MicroService`
and on `SingleHostApplication` today, so they are candidates to lift onto `Application`
while this is open.

### 2.6 `community.tosca.abstract.base` — one containment relationship, one requirement name

Three changes that are one idea: deployment layering is a single concept, so it should have a
single relationship type and a single requirement name, with the *capability* saying what kind
of thing is being placed. Reasoning in Problems 5 and 6.

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

**One requirement name.** `host` is the name TOSCA has used for deployment layering
throughout its history; `runs-on` and `available-on` are new names for that established
concept. Requirement names must be unique only *within* a node type (§3655), so each of the
three may declare `host`:

```yaml
node_types:
  Platform:
    requirements:
      - host:         { capability: PlatformHost,         relationship: HostedOn }
      - control-host: { capability: ExecutionEnvironment, relationship: HostedOn }
      - links-to:     { capability: Linkable,             relationship: LinksTo }
  Application:
    requirements:
      - host:      { capability: ExecutionEnvironment, relationship: HostedOn }
      - processes: { capability: DataSource,           relationship: Processes }
  Data:
    requirements:
      - host: { capability: DataPlatform, relationship: HostedOn }
```

**And a second name for the control plane.** `Platform` is the one type needing two placements
— its data plane and its control plane — and they cannot share a name, since names are unique
within a type. Declaring one `host` with an unbounded `count_range` and distinguishing the
assignments by `capability` is legal grammar but not usable: a TOSCA path selects a
requirement by name and index, never by capability, so a realization could not tell which
bindings are which. Hence `control-host`, reading with `host` as the pair it is — *where my
data plane is hosted*, *where my control plane is hosted*.

`control-host` is a placeholder for whatever the community prefers, provided it is
relation-shaped like its neighbours rather than naming a thing.

**Migration.** `RunsOn` and `AvailableOn` are retained as deprecated aliases for one release,
as are the `runs-on` and `available-on` requirement names, so existing templates keep parsing
while they are updated.

---

## 3. Problems and open issues

These were the proposed changes **as ported directly from the Ubicity
extension profiles**. Doing so surfaced the following problems, which are the
real reason this is a discussion document rather than a pull request.

### Problem 1 — Inconsistent typing of `mgmt-address` (`string` vs `IPv4Socket`)

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
> consumer can pin to a release instead of to a moving `master`. See Question 3.

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
definitions instead of maintaining their own (see Question 3 below).

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

Proposed replacement in Section 2.5. **Not yet discussed by the community.**

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

Proposal in Section 2.6. **Not yet discussed by the community.**

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

Proposal in Section 2.6. **Not yet discussed by the community.**

---

## 4. Decisions and open questions

1. **`mgmt-address` typing** — *Resolved (2026-06-24):* keep the property name
   and type specific to each derived platform type — a structured socket for
   servers, a `string` or platform-specific `JSON` for URL-addressed API
   platforms. Do not hoist a single `mgmt-address` onto the base `Platform`.
2. **`credential` typing** — *Resolved (2026-06-24):* likewise platform-specific
   — a structured `Credential` for login-based servers, a `string`/`JSON` for
   opaque token/config artifacts. No base-level harmonization.
3. **Single source of truth for shared types** — *Open, but the blocker is
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

   **This question is now forced by N8, and the two have to move together.** The
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

4. **Release process** — *Automation shipped (PR #350, July 2026); no release cut
   yet.* The mechanism described in Problem 3 is in place and unfired. Remaining:
   push the first tag, and write the versioning/governance documentation — including
   the rule that profile name-version strings are bumped when a version is frozen
   and the next one opened, since CSAR names derive from those strings rather than
   from the git tag.
5. **`SingleHostApplication`** — *Open, not yet discussed.* Three questions, of
   descending independence. Does the `processes` property belong at the System View at
   all, given that a `command` names an executable? Should a type be named for a
   cardinality it does not constrain, or should cardinality be a `count_range` on
   `runs-on`? And separately from both: the property `processes` collides with the
   requirement `processes` inherited from `Application`, which needs resolving on its
   own terms. Proposal in Section 2.5, reasoning in Problem 4.
6. **The control-plane requirement** — *Open, not yet discussed.* The platform README
   describes a second deployment requirement on `Platform`, distinguishing where a platform's
   control plane is deployed from where its data plane is. `Platform` does not declare it, so
   the README's own multi-node Kubernetes model cannot be expressed. Declaring it also forces
   the README's open question about naming, since `runs-on` already means *where this
   application executes*. Proposal in Section 2.6, reasoning in Problem 5.
7. **One containment relationship, one requirement name** — *Open, not yet discussed.*
   `HostedOn`, `RunsOn` and `AvailableOn` are identical but for the capability each accepts,
   and the profile marks all three `relationship_kind: containment`. Should they collapse into
   `HostedOn`, and should `runs-on` and `available-on` collapse into `host` — the name TOSCA
   has used for deployment layering throughout its history — leaving the capability to say what
   kind of thing is being placed? Proposal in Section 2.6, reasoning in Problem 6. Settling
   this also settles question 6, since the control-plane requirement is then a second
   requirement name over the same relationship.
