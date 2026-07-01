# Proposed Enhancements to the TOSCA Community Abstract Profiles

**Status:** Discussion draft — updated with the outcomes of the 2026-06-24
TOSCA Community meeting (pending review by Roberto)
**Audience:** TOSCA Community
**Purpose:** Capture a concrete set of proposed enhancements to the community
abstract profiles, together with the problems uncovered while prototyping them
and the decisions reached during community discussion.

**Related documents:** [README](README.md) · [prior-art](prior-art.md) · [design-guide](design-guide.md) · [meeting-history](../../../governance/meeting-history.md) · [decision-log](../../../governance/decision-log.md) · [open-issues](../../../governance/open-issues.md)

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
| `VirtualizationPlatform` | `mgmt-address: string` (opt), `credential: string` (opt) | `runs-on` → `ExecutionEnvironment` / `RunsOn` |
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

There is currently **no formal release process** for the community profiles:

- no git tags and no published releases,
- no release automation,
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

---

## 4. Decisions and open questions

1. **`mgmt-address` typing** — *Resolved (2026-06-24):* keep the property name
   and type specific to each derived platform type — a structured socket for
   servers, a `string` or platform-specific `JSON` for URL-addressed API
   platforms. Do not hoist a single `mgmt-address` onto the base `Platform`.
2. **`credential` typing** — *Resolved (2026-06-24):* likewise platform-specific
   — a structured `Credential` for login-based servers, a `string`/`JSON` for
   opaque token/config artifacts. No base-level harmonization.
3. **Single source of truth for shared types** — *Open:* should `Credential`,
   `IPv4Socket`, etc. be owned solely by `community.tosca.core`, with other
   profiles importing rather than redefining them? (Tied to the release-process
   item below.)
4. **Release process** — *In progress (2026-06-24):* keep `0.1` for now; freeze
   it once stable; plan version tracking and a formal release process that
   publishes immutable release artifacts (CSAR files raised as a candidate
   mechanism).
