# TOSCA Community — Proposed Agenda (2026-10-21)

**Status:** Draft agenda for 2026-10-21, following 2026-10-07 (2026-10-14 was cancelled)
**Related documents:** [kubernetes-modeling](../profiles/community/tosca/docs/kubernetes-modeling.md) · [association-proposal](../profiles/community/tosca/docs/association-proposal.md) · [design-patterns](../profiles/community/tosca/docs/design-patterns.md) · [application README](../profiles/community/tosca/abstract/application/README.md) · [open-issues](open-issues.md) · [decision-log](decision-log.md)

The `0.2` is organized around the Online Boutique (R8). Roberto has brought the abstract template
to the revised profiles, and Part 2 reviews it. His main concern is with the `Endpoint`
capability, and that concern and the changes he proposes motivate Part 3, on the capability types
the abstract application profile uses, and Part 4 revisits the hierarchy of its node types. Part 5
takes up discussion 384, on what the profiles' implementations are for, and Part 6 carries the
10-07 items that were not reached.

---

## Part 1 — Since 10-07 — 5 min · **presentation**

- **`ContainerPlatform` says how many nodes it spans.** Its new `size` property (N22) is an
  integer defaulting to 1, and the cluster example takes its agent count from it rather than from
  `implementation-details`. Trying it against the Kubernetes realizations and Docker Swarm, as
  agreed on 10-07, waits on a `0.2` release.
- **`ContainerPlatform` accepts only the credentials a container platform's API uses** (N19). Its
  `credentials` accept four kinds, one for each way such an API authenticates a client:
  `kubeconfig` for a Kubernetes cluster, whose kubeconfig file carries the server and the user
  together; `token` for an API that takes a bearer token, such as a Kubernetes service account's;
  and `x509_cert` and `x509_key` for one that authenticates clients with TLS, such as a Docker
  daemon on a TCP port. The SSH kinds are not among them, since an SSH login opens the host the
  platform runs on, and that host's own `ServerPlatform` carries them.
- **`ContainerPlatform` accepts only the addresses a container platform's API is reached at**
  (N19). Its `mgmt-address` admits three schemes, one for each way such an API is reached: `https`
  for a Kubernetes API server, which serves only over TLS; `tcp` for a remote Docker daemon, the
  scheme Docker uses for its daemon address; and `unix` for a daemon on the same host, reached
  through its local socket. An `http` address no longer validates, since no container platform
  the profile covers serves its API that way.

---

## Part 2 — The abstract Online Boutique, revised — 10 min · **first reading** · *R8*

Roberto circulated a revision by email on 10-15 that brings the abstract template to the revised
profiles: a `cluster` node of type `ContainerPlatform` that every microservice is hosted on,
`technology` and `implementation-details` on every node, and the implementation details taken as
inputs. None of this has been agreed.

**Roberto's main concern is the `Endpoint` capability.** Every microservice in the template has to
assign `Endpoint`'s `port` and `target-port`, and the values are technology-specific: `frontend`
maps port 80 to 8080 and `email` 5000 to 8080, a translation that means nothing above the
Kubernetes realization. An abstract profile and an abstract template are not the place for them,
and he proposes that the values travel in `implementation-details` instead, supplied by the user
and passed to the substituting template as is.

**Input wanted:** whether the template's structure is the one the `0.2` builds on, and what
should change before it goes into the repository, beyond what Part 3 decides.

---

## Part 3 — The capability types of the abstract application profile — 20 min · **decision sought** · *I56*

`Application` gives every application a `service` capability of the base type `Service`, and N11
rederived `Endpoint` from it for the network-addressable case. `MicroService` and
`ServerApplication` refine `service` to `Endpoint`, whose `port` and `target-port`, both required,
with `name` and `protocol`, are the fields of a Kubernetes Service port: an exposed port forwarded
to a container port. They come from the first draft of the application profile and were carried
through N11 and N12 unchanged.

**The same defect reaches `ServerApplication` harder.** Software on a server has no second port to
forward to, so it carries a `target-port` that means nothing, and software that serves nothing,
such as a command-line tool, cannot be typed `ServerApplication` at all. Ubicity found this
rederiving its server-hosted realizations, which stay on the base `Application` until it is
settled.

**Nothing at the abstract level needs the port.** In the interaction pattern of
[`kubernetes-modeling.md`](../profiles/community/tosca/docs/kubernetes-modeling.md#where-application-level-interaction-should-live),
a consuming Pod reads its peer's address and port from the peer's Kubernetes `Service`, reached
through the peer's capability mapping, at the device view.

**Three options for the `0.2`.** Each breaks any template that assigns the current properties,
which the `0.2` may do, since no compatibility is promised before `1.0`.

1. **Remove `Endpoint`.** `MicroService` and `ServerApplication` keep the inherited `Service`, the
   port values move to each microservice's `implementation-details`, as Roberto proposes, and the
   abstract Online Boutique follows. This follows N12's reasoning for dropping `processes`, that
   what runs on a host is below the System View.
2. **Keep `Endpoint` property-free**, as a marker of the network-addressable case, with the port
   values in `implementation-details` as in option 1.
3. **Keep `Endpoint` with a single `url` in place of its four properties**, of `core`'s `Url`
   type, as `mgmt-address` is on the platform types (N16). The scheme says how the service is
   reached, `grpc` between the Online Boutique's microservices and `http` for `frontend`, and the
   port is the one consumers connect to; the container port behind it is the realization's, so
   `target-port` goes. The property is the address the designer asks for, and its reflected
   attribute the address the realization produced, published through the substitution mapping.
   The host is usually not known until deployment, so the property is optional, and `Url`'s
   generic syntax already admits a URL that gives only a scheme and a port. This answers the
   paragraph above in part: a template's output of where the shop is reachable does need the
   address at the abstract level. `MicroService` and `ServerApplication` keep `Endpoint`, which
   removes the meaningless `target-port` from server software but still leaves no place for
   software that serves nothing, which Part 4 takes up.

**Decision sought:** which of the three, and, for options 1 and 2, whether the port values belong
in `implementation-details`.

---

## Part 4 — The abstract application node types — 15 min · **first reading**

The profile distinguishes its four node types along two axes, whether a node stands for a whole
application or for one component of one, and which kind of platform it is deployed on.
`MicroServiceApplication`, `ServerApplication` and `ServerlessApplication` each narrow `host` to
one platform type. `MicroService` narrows nothing, though the README says it is deployed on a
`ContainerPlatform`.

**The platform axis decides placement in the type.** `Application` declares `host` against any
`Host`, and a template that must pin a platform can do so in its `host` assignment, with a `node`
or a node filter. A type that pins it takes that choice from every template, before a realization
is selected (D15). It is also why software that serves nothing, such as a command-line tool, has
no type: the only type for software on a server is one that advertises an `Endpoint`.

**Proposed:** distinguish the types by what an application does rather than where it runs.
`ServerApplication` is replaced by `ServiceApplication`, an application that provides a service
across the network, which refines `service` to `Endpoint` in whatever form Part 3 settles.
`MicroService` derives from `ServiceApplication`, and software that serves nothing is typed
`Application`.

**Open in the proposal:**

- **What `MicroService` adds.** With no platform of its own it needs a meaning beyond
  `ServiceApplication`'s, or it is two types for one meaning (I1). Its candidate is a role, one
  component of a microservice application, substituted separately from its peers. The
  alternative is to drop it in favour of `ServiceApplication`.
- **Whether the whole-application types keep their platforms.** `MicroServiceApplication` pinning
  `ContainerPlatform` is placement in the type in the same way. `ServerlessApplication` may
  differ, if serverless is a programming model rather than a platform choice, since code written
  as functions does not run as a server.

**Input wanted:** whether the platform axis goes, and the two open points.

---

## Part 5 — What a profile's implementations are for — 15 min · **decision sought** · *I9, I55* · [#384](https://github.com/oasis-open/tosca-community-contributions/discussions/384)

Roberto's question about `$now` became the most active thread since 10-07. Tal objects to the
profiles carrying a calling convention and Python implementations: a reader may take them for
common practice, and an orchestrator built on Kubernetes, Ansible or Terraform has nowhere to run
an executable, so a profile that appears to require one tells that community TOSCA is not for
them. My position is that a profile is a standard library: the implementations make the function
grammar executable rather than only declared, show semantics a `description` cannot (Roberto read
`now.py` to learn that `$now` returns whole seconds in UTC), and run today.

Two facts narrow the disagreement, and the profiles state neither. The community profiles ship
function implementations only, so the one convention they rely on is an entry point named after
the function that takes the ordered argument list and returns one value. And §10.4 makes
`implementation` optional on a signature, while §18.4 asks of an orchestrator only that it process
functions by Chapter 10's rules, which let a designer rely on the orchestrator's own support. The
signature is the contract; the artifact is one way to satisfy it.

What would let `core` declare a signature once and leave the implementation to a profile written
for a particular execution environment is one profile refining another's function definition,
which §10.4 does not address (I55). Whether the existing rule already covers it, which would make
it an erratum, or it is a 2.1 feature, is the TC's to say.

**Decision sought:** state in the profiles that the signature is the contract and the artifact one
implementation of it; and whether, for the `0.2`, the implementations move out of `core`, the
direction I9 records. **Input wanted:** Tal's view, which the discussion has and the room may not.

---

## Part 6 — Carried from 10-07 — 15 min · **first reading**

### 6.1 What an association in the technology column may carry · *I54* · [proposal](../profiles/community/tosca/docs/association-proposal.md)

System View relationship types carry no operations, the consequence A8 rests on: substitution
replaces a node's operations with the substituting template's workflows, and nothing replaces a
relationship's, so an operation on an abstract relationship has nothing to implement it. The
question is open in the technology column. There an association that does nothing leaves no
model for two components that configure each other, each needing the other to exist and neither
needing it first: two dependencies form a cycle, and the association has nowhere to run the
configuration. Proposed: an association in the technology column, `technology.base`'s
`AssociatesWith` and the types derived from it, orders neither end and may carry operations that
connect its ends once both exist, never the ordered operations of a dependency. In both columns,
a source that needs its target first is a dependency. Independent of I44.

### 6.2 Requirement refinement in the specification · [#377](https://github.com/oasis-open/tosca-community-contributions/discussions/377)

§6.4.2 says a refinement need not restate an inherited keyname, but the keyname tables mark
keynames mandatory without saying "unless inherited", and at least one implementation follows the
tables. Tal proposes the tables say "mandatory if not derived". A candidate for the errata track
(P4), with I50 and I51, once spec work resumes.

**Input wanted:** any disagreement, and whether Tal files it.

---

## If time permits

- **What a platform is designated to be (I57)**: D15 has realizations select on a property
  saying what a platform is designated to become, and no platform type carries one. Its name, its
  values and whether it belongs on `Platform` or `Base` are open.
- **Where examples and substituting templates live (I53)**: Roberto or Stefano to circulate a
  proposal, from 10-07.
- **I44, the relationship kind**: carried until more participants attend. Tal has not been asked.
- **Orchestrated credentials (I27, I41)**, **implementations for functions and operations (I43)**,
  **the artifact calling convention (I10)**.
- **A pinned announcement in Discussions**, deferred on 09-30.

---

**Input wanted (Part 2):** whether the revised Online Boutique is the template the `0.2` builds on.

**Decision sought (Part 3):** whether `Endpoint` is removed, kept property-free or kept with a
`url`.

**Input wanted (Part 4):** whether the application node types stop naming a platform, with
`ServiceApplication` replacing `ServerApplication`.

**Decisions sought (Part 5):** what the profiles say their implementations are, and whether
they move out of `core` for the `0.2`.

**Also sought (Part 6):** whether the refinement erratum goes forward (6.2).
