# Proposed Enhancements to the TOSCA Community Abstract Profiles

**Status:** Discussion draft, holding the proposals still open. Section 2.3 was agreed at the
2026-09-02 community meeting on the requirement name and carries an open amendment (I46);
Section 2.4 was agreed there with two items reopened (I28, I29); Section 2.7 is in the profiles
except the part that waits on Section 2.3. Each proposal states its own status.

**A section leaves this document once it reaches the profiles**, in two directions: the decision
to the [decision log](../../../../governance/decision-log.md), and the description of the types to
the README of the profile that declares them. A section that has been implemented is a third copy
of both. What stays here is what is still proposed or still open. Section, problem and question
numbers are not reused, so a gap in the numbering is a section that has left.
**Audience:** TOSCA Community
**Purpose:** Capture a concrete set of proposed enhancements to the community
abstract profiles, together with the problems uncovered while prototyping them
and the decisions reached during community discussion.

**Related documents:** [README](../README.md) · [prior-art](prior-art.md) · [modeling-methodology](modeling-methodology.md) · [meeting-history](../../../../governance/meeting-history.md) · [decision-log](../../../../governance/decision-log.md) · [open-issues](../../../../governance/open-issues.md)

**How this document is organized.** Four parts, which cross-reference each other by number.
**Section 1** says why these changes are being proposed. **Section 2** is the proposals still
open, grouped by profile in the order the profiles build on each other, each carrying its own
status. **Section 3** is the reasoning, as numbered problems, and most Section 2 proposals point
at the problem that motivates them. **Section 4** is the questions still open, as numbered
questions — so a reference to "question 6" anywhere above means that entry there.

---

## 1. Background and motivation

The community abstract profiles — `community.tosca.core` and the five
`community.tosca.abstract.*` profiles (`base`, `platform`, `data`, `application`,
`network`) — define most of their node types as essentially *description-only*: they carry a
`derived_from` and a description, but few or no properties and requirements. All six platform
types declare no properties at all.

Ubicity maintains a set of **extension profiles** (`com.ubicity.abstract.platform`,
`com.ubicity.abstract.network`, and the empty `com.ubicity.abstract.application` and
`com.ubicity.abstract.data`, which carry realizations only) whose purpose is to derive from the
community types and add the properties and requirements needed to actually use them: management
address, credentials, hosting requirements, a network's address range.

The goal of this proposal is to **fold those features into the community
profiles**, so the extension profiles are no longer necessary and downstream
templates can rely on the community types directly. Prototyping this exposed
several issues — documented in Section 3 — that should be settled by the
community first.

---

## 2. Proposed changes

### 2.3 `community.tosca.abstract.base` — one containment relationship, one requirement name

**Status: agreed 2026-09-02 on the requirement name; the relationship-type collapse is
deliberately left open.** Recorded as decision N9. Roberto proposed the three relationship
types originally, at a point when it was not yet known whether each would need distinct
properties or attributes; months of use show they do not. So `host` is the requirement name
everywhere and the base `HostedOn` is what it declares, and a derived relationship type
returns if and when one earns its keep by carrying properties, attributes or interface inputs
of its own — which the requirement name absorbs without change. **One further constraint came
out of the discussion:** restrict on the capability side or the relationship side, not both.
Declaring `valid_capability_types` and `valid_relationship_types` for the same connection
states the constraint twice, and the connection binds only while the two lists agree; once they
drift apart, nothing binds. Reasoning in Problems 5 and 6.

Deployment layering is a single concept, so it should have a single relationship type and a
single requirement name, declared once on `Base`, with the *capability* saying what kind of
thing is being placed.

This is the [Component/Port pattern](design-patterns.md#componentport-pattern) applied to
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

**Proposed amendment: one hosting capability, permissive at the base.** *Proposed 2026-09-11;
not yet discussed.* N9 unified the requirement name and kept the three capability types, on the
reasoning that the capability says what kind of thing is being placed. The argument that makes
the three relationship types redundant applies to the three capabilities as well: one
capability type, exposed once by `Platform` and accepting every kind of guest, narrowed by a
derived platform type where that platform accepts fewer. Reasoning in Problem 8.

```yaml
capability_types:
  Host:                                 # placeholder name; derived, not Container itself (N10)
    derived_from: Container

relationship_types:
  HostedOn:
    metadata:
      relationship_kind: containment
    derived_from: ContainedBy
    properties:
      implementation-details: { type: YAML, required: false }
    valid_capability_types: [ Host ]    # the one side constrained; Host names no relationships

node_types:
  Base:
    requirements:
      - host:
          capability: Host
          relationship: HostedOn

  Platform:
    capabilities:
      host:
        type: Host                      # no valid_source_node_types: every guest is accepted
    requirements:
      - control-host: { capability: Host,     relationship: HostedOn }
      - links-to:     { capability: Linkable, relationship: LinksTo }

  Network:
    requirements:
      - host: { count_range: [ 0, 1 ] }
```

Against the agreed sketch above:

- **One capability instead of three.** `PlatformHost`, `ExecutionEnvironment` and `DataPlatform`
  give way to a single type, and `Platform` exposes one capability. `PlatformHost` names one of
  the three roles, so the single type wants a neutral name; `Host` is a placeholder in the same
  spirit as `control-host`.
- **No child refines `host`.** `Platform`, `Application` and `Data` inherit it from `Base`
  unchanged, and `Network` narrows only its `count_range`. What is being placed is stated by the
  type of the source node, which every relationship already knows, rather than by the
  capability it targets.
- **A platform that accepts fewer kinds of guest says so in its own type**, by refining the
  inherited capability's `valid_source_node_types`, which a refinement may narrow but never
  widen (§8.2.1). As an illustration only — whether
  any community platform restricts its guests is a question for the platform profile:

  ```yaml
    ServerlessPlatform:
      capabilities:
        host:
          valid_source_node_types: [ Application ]
  ```

- **The relationship-type collapse N9 left open follows.** With one capability there is nothing
  for `RunsOn` or `AvailableOn` to accept that `HostedOn` does not.

This amends N9's wording rather than its substance: the requirement name stays `host`, declared
once on `Base`. The migration belongs to the same cut as the rest of this section. Beyond the
consumers N9 already affects, a substituting template that maps `execution-environment` or
`data-platform` by name maps `host` instead; the realizations that exist map all three onto the
same capability of the node they substitute, so they lose nothing.

### 2.4 `community.tosca.abstract.platform` — properties and requirements

**Status: agreed 2026-09-02, with two items reopened.** The six community platform types
declare no properties today. The credentials mechanism is decision D13; the two open items are
the `mgmt-address` type and the container-platform vocabulary, both flagged in the table below.

`credentials` is declared once on `Platform`, as a map of the `CredentialRef` `core` declares (D13). What each
platform type adds is the **vocabulary of credential kinds it accepts**, as a `key_schema`
refinement — §9.4 permits refining a `key_schema`, and a refinement's validation clause is
considered *in addition to* the parent's, so a derived type narrows and cannot widen.

| Node type | Added properties | Added requirements |
|-----------|------------------|--------------------|
| `ServerPlatform` | `mgmt-address: IPv4Socket` (opt) †, `credentials` keyed `[ssh_key, ssh_password]` | `host` — inherited from `Platform` — refined to `node: VirtualizationPlatform` |
| `VirtualizationPlatform` | `mgmt-address: string` (opt) †, `credentials` keyed `[token, cloud_account]` — a cloud account being a reference to a provider config file such as an AWS one, which holds the token and optionally the region | the control-plane requirement — see Section 2.3, which declares it on `Platform` under a name of its own |
| `ContainerPlatform` | `credentials` keyed `[kubeconfig]` ‡ | — |

**† The `mgmt-address` type is reopened (2026-09-02).** Roberto's alternative is to type it as a
URL rather than as a structured socket for one platform kind and a bare string for another —
general, and validated in both cases. What has to be established first is whether every
management address can be written as a URL. The reason to settle it before the `0.1` rather than
after: a data type chosen at this level cannot be corrected at any lower one. Tracked as I28, and
it reopens the 2026-06-24 resolution of [Question 1](#question-1--mgmt-address-typing).

**The validated URL type in `core` is not that type.** `HttpUrl` accepts only `http` and
`https`, so the URL route needs a URL type that does not fix the scheme, leaving the scheme to say
how the platform is reached.

**An SSH address can be written as a URL, and doing so cites a convention rather than inventing
one (checked 2026-09-11).** There is no RFC: the IETF draft that defined the scheme,
`draft-ietf-secsh-scp-sftp-ssh-uri`, expired in 2006. But IANA holds a provisional registration
of `ssh`, as `ssh://[<user>[;fingerprint=<host-key fingerprint>]@]<host>[:<port>]`, and deployed
tools agree on its core: OpenSSH accepts `ssh://[user@]hostname[:port]` as a destination, Git
addresses repositories as `ssh://[user@]host[:port]/path`, and Docker takes `ssh://user@host` as
a daemon address. They differ only where a management address has no need to go — what a path
means, which the draft says to ignore and Git and Docker each use for their own purpose; the
draft's `;fingerprint=` parameter, which none of those tools documents; and whether a user is
given. So the convention to adopt is the common subset, **`ssh://host[:port]`**, with port 22
when none is given, declared in `core` as `SshUrl` (below):

- **no path**, since its meaning is application-specific;
- **no user**, since the login name is the credential's `name`, and a second source for it could
  disagree with the first;
- **no `;fingerprint`**, since a host-key fingerprint is trust material and belongs on a trust
  port (I41), not in an address;
- **a host as RFC 3986 defines one**: a DNS name, an IPv4 address or a bracketed IPv6 literal.

The IANA template marks the scheme's encoding, interoperability and security as "unknown, use
with care", the standard wording for a provisional registration, which is a reason to name the
subset rather than cite the registration unqualified. The container-platform endpoints listed
under ‡ below — `tcp://`, `unix://`, `https://` — are URLs of the same kind.

**If the address is a URL, it is declared once, on `Platform`.** It is declared per platform type
today only because the types differ, a socket on one and a string on another, and a URL type that
does not fix the scheme covers every case. It then belongs where `credentials` already is: the two
answer one question, how the orchestrator reaches the platform. `Base` is the wrong level.
`Application`, `Data` and `Network` are deployed onto platforms and managed through them, and an
application's endpoint is a contract for its consumers (N11), not a management address.

**Each platform type then narrows the address, as it narrows its credentials:**

| Property | Declared once on `Platform` as | Narrowed per platform type by | A realization dispatches on |
|----------|--------------------------------|-------------------------------|-----------------------------|
| `credentials` | a map of `CredentialRef` | a `key_schema` refinement, to the kinds it accepts | the key |
| `mgmt-address` | a `Url` | refining the type to a scheme's own type where one scheme is admitted; a validation over the schemes where several are | the scheme |

**Two mechanisms, because they do two jobs.** What a URL of a given scheme looks like is a fact
about the scheme, so it belongs in a type declared once, as `HttpUrl` already does for `http` and
`https` and `SshUrl` below does for `ssh`. Which schemes a property admits is a fact about the
property, and it has to stay a validation wherever there is more than one: TOSCA has no union
types (I24), so no single type can say "one of these three".

| Platform type | `mgmt-address` narrowed by |
|---------------|----------------------------|
| `ServerPlatform` | refining the type to `SshUrl` |
| `VirtualizationPlatform` | refining the type to `HttpUrl` |
| `ContainerPlatform` | a validation admitting `https`, `tcp` and `unix`, the type staying `Url` |

A refined type must derive from the parent's, and a refinement's validation applies in addition to
the parent's (§9.4), so either way a derived type narrows the address and cannot widen it, which is
the rule that bounds the credential vocabulary too. Only schemes whose syntax the community fixes
get a type of their own. Any other scheme is `Url` narrowed on the property, so that, as with a new
credential kind, a new scheme needs no change to `core`.

**Two consequences follow.** Declaring it on `Platform` commits every platform to the URL family,
since a derived type can narrow the property but cannot take it outside `Url`. Enumerating the
remaining cases, `PaasPlatform`, `SaasPlatform` and `ServerlessPlatform` among them, is therefore
the precondition for the move, and part of settling I28 before the `0.1`. And it supplies the
address the ‡ resolution below gives `ContainerPlatform`, which then inherits one rather than
declaring its own.

**The cost of the URL route is that a URL has to be parsed to be read in parts.** A structured
socket yields its host by path, as `[mgmt-address, ip-address]`. A URL yields a host and a port
only by parsing, and the built-in functions do not parse one: `$token` returns the substring at a
fixed index between separator characters, so it cannot read a port that may be absent, or a
bracketed IPv6 host whose colons are themselves separators. A realization would otherwise have to
hand the whole URL to an artifact that parses it. That is the main argument against the URL
route, and `core` can answer it.

**What `core` would add if the route is taken.**

- **A `Url` type that validates RFC 3986's generic syntax**, `scheme ":" hier-part [ "?" query ]
  [ "#" fragment ]`, rather than any one scheme's rules, so that `unix:///var/run/docker.sock`
  validates as readily as `ssh://host:22`. Which schemes a property admits is its refinement's
  business, as the table above sets out. `core` is the home for the reason it is `CredentialRef`'s:
  typing is nominal, so the abstract property and every profile that assigns or reads it must name
  one declaration. `HttpUrl` then derives from `Url`, keeping its stricter pattern as the
  refinement's added validation, so that an `HttpUrl` value is a `Url` and anything typed `Url`
  accepts one. That change breaks nothing: `HttpUrl`'s values and validation are unchanged, and its
  parent moves from `string` to a type that is itself a string. As I26 asks of `core`'s other
  patterns, `Url` should carry test cases, since a generic URL pattern is harder to get right than
  `HttpUrl`'s.
- **An `SshUrl` type derived from `Url`**, holding the subset adopted above: the `ssh` scheme, a
  host and an optional port, and nothing else. The convention is then stated once rather than
  repeated on every property that admits `ssh`, and a realization that receives one can rely on
  there being no path and no user in what it parses. It carries test cases for the same reason
  `Url` does.
- **A function that reads a URL's parts. This one is required.** An address supplied to the
  abstract node travels *down* to technology types that want its host and its port apart, and no
  built-in function can take them out reliably. It returns one part at a time — scheme, host, port
  or path — rather than a decoded structure, because a function's result cannot be followed by a
  path, so a structure would be unusable where a realization needs the host. For a part the URL
  does not carry, it returns a default the caller passes, such as 22 for an `ssh` port. The default
  has to be an argument: TOSCA has no built-in function that substitutes one for an absent value,
  and RFC 3986 recommends leaving out a port that equals the scheme's default, so a well-formed
  `ssh://host` often carries no port at all.
- **A function that composes one.** An address a realization produces travels *up* — a
  provisioned server's IP address and port becoming its platform's `mgmt-address` — and has to be
  assembled. `$concat` covers a DNS name or an IPv4 address, but produces an invalid URL from an
  IPv6 host, which must be bracketed, and cannot leave out a port that is absent. A composing
  function that brackets the host, omits an absent port and validates its result keeps what a
  realization produces as valid as what an author assigns.

The two functions follow the two directions a credential also travels, supplied downward and
produced upward, which is why they come as a pair. Like `core`'s other functions they would be
implemented in Python, which I43 notes is the only implementation a profile can carry for a
function today.

**How a realization translates across the boundary.** Property mapping requires the two sides'
types to match (§15.2), so the translation is not in the mapping. It sits in the substituting
template's own inputs and outputs, between a boundary-typed value and the technology types below,
in the form the [modeling methodology](modeling-methodology.md#passing-implementation-details-across-a-substitution-boundary)
uses for `implementation-details`: a mapped input of the abstract type, and a second input whose
`value` a `core` function derives from it, there `$decode_yaml`. In the sketches below,
`$url_part` and `$compose_url` stand for the two functions above; naming them is the group's
call.

Downward, for a realization onto a server whose technology types take a socket:

```yaml
inputs:
  mgmt-address:              # boundary-typed: exactly the abstract node's type
    type: SshUrl
  mgmt-socket:               # derived: what the technology types below expect
    type: IPv4Socket
    value:
      ip-address: { $url_part: [ { $get_input: mgmt-address }, host ] }
      transport-port: { $url_part: [ { $get_input: mgmt-address }, port, 22 ] }
```

Upward, for a realization that provisions the server and reports its address:

```yaml
substitution_mappings:
  attributes:
    mgmt-address: mgmt_url
outputs:
  mgmt_url:
    type: SshUrl
    value: { $compose_url: [ ssh, { $get_attribute: [ server, address ] } ] }
```

**The downward translation can lose information; the upward one cannot.** A URL's host may be a
DNS name or a bracketed IPv6 literal, and `IPv4Socket` types its host as `IPv4`, which holds
neither. A realization whose technology types need an IPv4 literal says so in its substitution
filter, which is one more place the reading function is used. A socket always composes into a URL.

**The cost is paid once per realization.** Nothing below the boundary changes: the translation is
written in each realization's inputs and outputs, not in the node templates or artifacts it
deploys.

**‡ `[kubeconfig]` is too restrictive** and was agreed on 2026-09-02 to be an oversight rather
than a position. A container platform can equally be Docker with Compose, Docker Swarm or Nomad,
none of which authenticate with a kubeconfig. Tracked as I29.

**Proposed resolution (2026-09-11).** The kinds follow from what a connection opens: a platform
records how the orchestrator reaches it on the node that connection opens, as the
[credential orchestration proposal](credential-orchestration-proposal.md) puts it. That gives
`ContainerPlatform` four kinds:

| Kind | What the connection opens | Used by |
|------|---------------------------|---------|
| `kubeconfig` | the cluster API; the file carries its endpoint and its CA | every Kubernetes distribution |
| `token` | the platform's HTTP API | Nomad's ACL token; a Kubernetes bearer token held without a kubeconfig |
| `x509_cert`, `x509_key` | the platform's API, over mutual TLS | a remote Docker daemon — and so Compose and a Swarm manager, which speak its API — and Nomad with mutual TLS enabled |

Three kinds are absent on purpose. **`ssh_key` and `ssh_password` open the host.** A Docker
`ssh://` endpoint, a remote Podman and a runtime reached through its local socket are all reached
by logging into the machine the platform runs on, so that login belongs on the `ServerPlatform`
hosting the platform; declaring it here as well would give one login two homes. **`cloud_account`
opens a cloud account**, which is the `VirtualizationPlatform`'s; a managed cluster's kubeconfig
uses it from there. **`password`**: nothing in this class authenticates its orchestrator with HTTP
Basic.

**The vocabulary is a ceiling, so it is a union.** A refinement narrows and cannot widen (§9.4),
so what the abstract type admits bounds every realization of it, and each realization reads the
kind it consumes.

**Two things the vocabulary cannot supply on its own.**

- **An address.** A token or a client certificate is presented *to* an endpoint, and
  `ContainerPlatform` declares none; a kubeconfig needs none only because it carries its server's
  URL. The extension therefore needs an optional `mgmt-address`: inherited from `Platform` if I28
  declares it there as a URL, and declared on `ContainerPlatform` otherwise. The
  endpoints in question — `tcp://host:2376`, `unix:///var/run/docker.sock`, `https://host:4646`,
  `https://host:6443` — carry a scheme, and one is a socket path rather than a host and port.
- **Trust.** The x509 kinds, like a token sent over TLS, verify the server against a CA. That is
  trust material rather than credential material and belongs on a trust port of its own, not in
  this map (I41).

**Sequencing.** Widening a `key_schema` is not a breaking change: every value that validated
still validates, and every narrower refinement downstream still lies within the wider set; it is
narrowing that breaks. So `0.1` can ship `[kubeconfig]` as the table shows, and the three further
kinds arrive in `0.2` together with `mgmt-address` and the trust requirement — which also keeps a
template from supplying a kind that no realization can yet use. The mechanisms in the table are to
be confirmed against each platform's documentation before they are written into the profile.

`PaasPlatform`, `SaasPlatform` and `ServerlessPlatform` are not addressed. Nothing has been
prototyped against them, so there is no evidence yet for what they would need.

### 2.7 `community.tosca.abstract.application` — `ServerApplication`'s placement requirement

**Status: agreed 2026-09-02 as decision N12, and in the profiles except the placement
requirement.** `ServerApplication` has replaced `SingleHostApplication`, without `processes`, and
is described in the [application profile README](../abstract/application/README.md). What remains
waits on Section 2.3 (N9): the placement requirement becomes `host`, and cardinality becomes a
`count_range` on it. Reasoning in Problem 4.

```yaml
node_types:
  ServerApplication:
    derived_from: Application
    requirements:
      - host:
          capability: ExecutionEnvironment
          node: ServerPlatform           # Section 2.3
```

**Cardinality is a `count_range` on `host`**, in the type where a kind of application genuinely
constrains it and in the template where it does not. An application spanning several servers
becomes `host` bound several times, which is the same form the platform profile already uses for a
cluster spanning several servers: one way to say "how many", at both layers, instead of a type per
cardinality.

---

## 3. Problems and open issues

These were the proposed changes **as ported directly from the Ubicity
extension profiles**. Doing so surfaced the following problems, which are the
real reason this is a discussion document rather than a pull request.

### Problem 4 — Cardinality belongs on the placement requirement, not in a type name

`SingleHostApplication` was named for a cardinality it did not constrain. Its placement
requirement declared no `count_range`, so it took the `tosca_2_0` default of `[0, UNBOUNDED]` and
permitted any number of hosts. "Single host" is a placement constraint, and a placement constraint
is a `count_range`, not a type. A type per cardinality also does not scale: the same reasoning
would want a type for two hosts, and another for many. N12 renamed the type for the platform it
targets; the `count_range` waits on the placement requirement Section 2.3 renames.

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

- **The Component/Port pattern argues against the split.** Its naming principle holds that
  *capability* type names describe the functionality a component exposes, while *relationship* type names
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

### Problem 8 — Three hosting capabilities that every platform exposes

`Platform` declares three capabilities — `host` of type `PlatformHost`, `execution-environment`
of type `ExecutionEnvironment` and `data-platform` of type `DataPlatform` — and every platform
type inherits all three. N9 kept them when it unified the requirement name, but they share the
property Problem 6 found in the relationship types:

| | parent | properties | attributes | exposed by |
|---|---|---|---|---|
| `PlatformHost` | `Container` | none | none | every `Platform` |
| `ExecutionEnvironment` | `Container` | none | none | every `Platform` |
| `DataPlatform` | `Container` | none | none | every `Platform` |

- **They are one capability under three names.** Same parent, nothing declared. The
  realizations that exist confirm it from the other side: a substituting template maps all
  three onto the same capability of the node it substitutes.

- **They do not tell platforms apart.** A derived type cannot remove an inherited capability,
  so every platform advertises all three kinds of hosting — a serverless platform claims to
  hold data and to host other platforms. What remains for restricting one is to narrow its
  `valid_source_node_types`, which does with three capabilities what one does alone.

- **A requirement cannot ask for more than one of them.** A requirement names a single
  capability, so a component has no way to ask for a platform that hosts both applications and
  data. Since every platform exposes all three, the answer would be yes regardless — the split
  carries no information a placement could use. With one capability, what a platform accepts is
  stated in one place, and every guest bound to it is checked against that one list: an
  application and its data placed on the same platform each pass or fail against the same
  `valid_source_node_types`.

- **The vocabulary does not fit the guests it has.** Four kinds of node are placed — platforms,
  applications, data and networks — against three capabilities, so `Network` borrows
  `PlatformHost`, which reads as hosting a platform. Another kind of guest would need another
  capability on `Platform`. One capability that says only *can host* fits every guest.

- **Permission belongs at the base, restriction below it.** Refinement narrows (§5.1.3): a
  derived type may tighten a property's validation (§9.4), a requirement's `count_range`
  (§8.4.1) or a capability's `valid_source_node_types` (§8.1, §8.2.1), but not loosen what its
  parent allowed. So a restriction declared at the base binds every type beneath it, while a
  permission granted at the base can be withdrawn by any one of them. The flexible arrangement
  is a base as permissive as the model needs and each derived type as restrictive as its
  technology demands. Three capabilities on the base grant all three kinds of hosting to every
  platform, and a derived type can withdraw one only by narrowing its sources.

  §8.2.1's wording, read literally, measures a capability refinement against the capability
  type rather than the parent node type's definition, which would let a derived node type widen
  a list its parent narrowed. That contradicts §5.1.3, §8.1 and the parallel §8.4.1, and is
  raised as errata in
  [oasis-tcs/tosca-specs#371](https://github.com/oasis-tcs/tosca-specs/issues/371); this
  proposal relies on the narrowing reading.

- **O-PAS already works this way.** Its control application components are placed through one
  requirement onto one capability of a distributed control node, and the node types derived
  from it — compute-only, I/O-only — narrow that capability's `valid_source_node_types` to the
  components each accepts.

- **Nothing is lost.** If a hosting role ever needs properties of its own, a capability type
  derived from the single one carries them. A requirement is satisfied by a capability of the
  type it names or of any type derived from it, so guests asking for the parent keep binding.

Proposal in the amendment to Section 2.3. **Not yet discussed by the community.**

---

## 4. Decisions and open questions

### Question 1 — `mgmt-address` typing

*Resolved (2026-06-24), reopened (2026-09-02).* The 2026-06-24 resolution: keep the property
name and type specific to each derived platform type — a structured socket for servers, a
`string` or platform-specific `JSON` for URL-addressed API platforms. Do not hoist a single
`mgmt-address` onto the base `Platform`.

What reopens it is not the per-type principle but the choice of types. Roberto proposes a
validated URL for every case, which is both general and checkable, against a structured socket
in one place and an unvalidated string in another. The question to settle is whether every
management address is expressible as a URL — SSH has no official scheme, so the community would
be publishing a convention of its own. Section 2.4 carries the detail; tracked as I28.

### Question 3 — Single source of truth for shared types

*Open, but the blocker is
gone (2026-08-23):* should `Credential`, `IPv4Socket`, etc. be owned solely by
`community.tosca.core`, with other profiles importing rather than redefining
them? The stated obstacle was that there is no immutable artifact to pin to, so
a consumer would be pinning to a moving `master`. **Release automation now
produces signed, checksummed CSARs (see [question 4](#question-4--release-process)), so tagging `0.1` removes
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

*Automation shipped (PR #350, July 2026); no release cut yet.* A pushed semver tag (`v0.1`,
`v0.1.0`, and rc variants) or a manual dispatch builds a CSAR per `community.tosca.*` profile,
named from the profile name-version, so `community.tosca.core:0.1` becomes
`community.tosca.core.0.1.csar`; signs every artifact with Sigstore keyless signing; publishes a
signed SHA256 checksum manifest; and opens a **draft** GitHub Release for review. The repository
still carries no tags. What the `0.1` waits on is tracked as I8 in
[`open-issues.md`](../../../../governance/open-issues.md). Owed with it: the versioning and
governance documentation, including the rule that profile name-version strings are bumped when a
version is frozen and the next one opened, since CSAR names derive from those strings rather than
from the git tag.

### Question 6 — The control-plane requirement

*Open, not yet discussed.* The platform README
describes a second deployment requirement on `Platform`, distinguishing where a platform's
control plane is deployed from where its data plane is. `Platform` does not declare it, so
the README's own multi-node Kubernetes model cannot be expressed. Declaring it also forces
the README's open question about naming, since `runs-on` already means *where this
application executes*. Proposal in Section 2.3, reasoning in Problem 5.

### Question 7 — One containment relationship, one requirement name

*Resolved in part (2026-09-02)* as decision N9: the requirement name is `host` everywhere, and
the relationship-type collapse is left open, to be undone only by a type that needs properties
or attributes of its own. The question as originally posed:
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

### Question 10 — One hosting capability

*Open (raised 2026-09-11).* Should `PlatformHost`, `ExecutionEnvironment` and `DataPlatform`
collapse into one hosting capability type, exposed once by `Platform` with no restriction on
its sources and narrowed by the derived platform types that accept fewer kinds of guest? Doing
so amends N9's wording, which leaves the capability to say what kind of thing is placed, and
settles the relationship-type collapse N9 left open. The single type also needs a name.
Proposal in the amendment to Section 2.3, reasoning in Problem 8.
