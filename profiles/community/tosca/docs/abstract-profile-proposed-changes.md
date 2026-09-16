# Proposed Enhancements to the TOSCA Community Abstract Profiles

**Status:** Discussion draft, holding the proposals still open. Section 2.4 was agreed at the
2026-09-02 community meeting and is in the profiles except I29. Each proposal states its own status.

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

**How this document is organized.** **Section 1** says why these changes are being proposed.
**Section 2** is the proposals still open, each carrying its own status. **Section 4** is the
questions still open, as numbered questions — so a reference to "question 3" anywhere above means
that entry there.

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
several issues that should be settled by the
community first.

---

## 2. Proposed changes

### 2.4 `community.tosca.abstract.platform` — properties and requirements

**Status: agreed 2026-09-02 as the write-up of decision N8, with two items reopened; the `mgmt-address` type
settled 2026-09-16 as decision N16, as a URL.** **`credentials` is in the profiles since
2026-09-16**, declared on `Platform` and narrowed per platform type as the table below shows,
and `core` declares `Url` and `SshUrl`, with `HttpUrl` derived from `Url`. `core` also declares
`Socket`, replacing `IPv4Socket`, and the two functions below as `ssh_url_to_socket` and
`socket_to_ssh_url` (2026-09-16), the three names for the group to confirm. **`mgmt-address` is in
the profiles since 2026-09-16**, declared on `Platform` as `Url` and narrowed to `SshUrl` on
`ServerPlatform` and `HttpUrl` on `VirtualizationPlatform`. `ContainerPlatform`'s stays `Url`
until I29 settles its schemes. `VirtualizationPlatform` also accepts
`ssh_key` since 2026-09-16, an addition to the table below for a platform managed partly through an
SSH login on a machine not modelled as a server platform. The credentials
mechanism is decision D13; the one item still open is the
container-platform vocabulary, with the URL schemes the container platform admits.

`credentials` is declared once on `Platform`, as a map of the `CredentialRef` `core` declares (D13). What each
platform type adds is the **vocabulary of credential kinds it accepts**, as a `key_schema`
refinement — §9.4 permits refining a `key_schema`, and a refinement's validation clause is
considered *in addition to* the parent's, so a derived type narrows and cannot widen.

| Node type | Added properties | Added requirements |
|-----------|------------------|--------------------|
| `ServerPlatform` | `mgmt-address: IPv4Socket` (opt) †, `credentials` keyed `[ssh_key, ssh_password]` | `host` — inherited from `Platform` — refined to `node: VirtualizationPlatform` |
| `VirtualizationPlatform` | `mgmt-address: string` (opt) †, `credentials` keyed `[token, cloud_account]` — a cloud account being a reference to a provider config file such as an AWS one, which holds the token and optionally the region | `control-host`, inherited from `Platform` |
| `ContainerPlatform` | `credentials` keyed `[kubeconfig]` ‡ | — |

**† The `mgmt-address` type is reopened (2026-09-02).** Roberto's alternative is to type it as a
URL rather than as a structured socket for one platform kind and a bare string for another —
general, and validated in both cases. What has to be established first is whether every
management address can be written as a URL. The reason to settle it before the `0.1` rather than
after: a data type chosen at this level cannot be corrected at any lower one. Tracked as I28, and
it reopened the 2026-06-24 resolution of Question 1, which N16 has since settled.

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
socket yields its host by path, as `[mgmt-address, address]`. A URL yields a host and a port
only by parsing, and the built-in functions do not parse one: `$token` returns the substring at a
fixed index between separator characters, so it cannot read a port that may be absent, or a
bracketed IPv6 host whose colons are themselves separators. A realization would otherwise have to
hand the whole URL to an artifact that parses it. That is the main argument against the URL
route, and `core` can answer it.

**What `core` adds.**

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
- **A `Socket` type replacing `IPv4Socket`**, with `address`, a string holding a DNS name, an IPv4
  address or an IPv6 address, and `port`, a `Port`. `IPv4Socket` typed its host as `IPv4`, which
  holds neither of the other two, so not every `SshUrl` converts into one. Its one user,
  `technology.base`'s `Bash.host`, uses `Socket` instead.
- **`ssh_url_to_socket`, for an address that travels *down*:** supplied to the abstract node as a
  URL, to technology types that want its host and its port apart, which no built-in function can
  take out reliably. It returns the whole socket, with the brackets removed from an IPv6 host and
  the port 22 where the URL gives none, as `SshUrl` defines. A realization that needs one part
  assigns the socket to an input and reads the part from that input by path.
- **`socket_to_ssh_url`, for an address that travels *up*:** a provisioned server's address
  becoming its platform's `mgmt-address`. `$concat` covers a DNS name or an IPv4 address, but
  produces an invalid URL from an IPv6 host, which must be bracketed. The function brackets it, and
  leaves out a port of 22, as RFC 3986 asks of a URI producer for a scheme's default port. It
  rejects port 0, which `Port` admits and a URL cannot name.

The two functions follow the two directions a credential also travels, supplied downward and
produced upward, which is why they come as a pair. Like `core`'s other functions they are
implemented in Python, which I43 notes is the only implementation a profile can carry for a
function today.

**How a realization translates across the boundary.** Property mapping requires the two sides'
types to match (§15.2), so the translation is not in the mapping. It sits in the substituting
template's own inputs and outputs, between a boundary-typed value and the technology types below,
in the form the [modeling methodology](modeling-methodology.md#passing-implementation-details-across-a-substitution-boundary)
uses for `implementation-details`: a mapped input of the abstract type, and a second input whose
`value` a `core` function derives from it, there `$decode_yaml`.

Downward, for a realization onto a server whose technology types take a socket:

```yaml
inputs:
  mgmt-address:              # boundary-typed: exactly the abstract node's type
    type: SshUrl
  mgmt-socket:               # derived: what the technology types below expect
    type: Socket
    value: { $ssh_url_to_socket: [ { $get_input: mgmt-address } ] }
```

Upward, for a realization that provisions the server and reports its address:

```yaml
substitution_mappings:
  attributes:
    mgmt-address: mgmt_url
outputs:
  mgmt_url:
    type: SshUrl
    value: { $socket_to_ssh_url: [ { $get_attribute: [ server, address ] } ] }
```

**Neither translation loses information.** Every host an `SshUrl` admits is a `Socket` address,
and a socket whose address is a host composes into an `SshUrl`.

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

---

## 4. Decisions and open questions

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
