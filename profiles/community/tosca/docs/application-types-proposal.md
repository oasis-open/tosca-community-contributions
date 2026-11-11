# The Abstract Application Types

*Drafted with an AI assistant (Claude); reviewed and submitted by Chris Lauwers.*

**Status:** Proposal — for discussion. Tracked as I58 and I56; carries out N24.
**Audience:** TOSCA Community.
**Purpose:** Reduce the abstract application types to the one distinction the models so far need,
an application that provides a service across the network, and leave where an application runs to
placement and substitution.

**Related documents:** [application profile](../abstract/application/profile.yaml) and its
[README](../abstract/application/README.md) · [Online Boutique](../../../../examples/online_boutique) ·
[modeling-methodology](modeling-methodology.md)

---

## The types today

The application profile derives four node types from the base profile's `Application`, which
gives every application a `service` capability of type `Service` and an `interacts-with`
requirement.

| type | narrows `host` to | refines `service` to | otherwise adds |
|---|---|---|---|
| `MicroServiceApplication` | `ContainerPlatform` | — | nothing |
| `MicroService` | — | `Endpoint` | nothing |
| `ServerApplication` | `ServerPlatform` | `Endpoint` | nothing |
| `ServerlessApplication` | `ServerlessPlatform` | — | nothing |

`Endpoint` carries `port`, `target-port`, `name` and `protocol`, the fields of a Kubernetes Service
port.

Three of the types differ from `Application` only in the platform they accept, which decides
placement in the type, before a realization is selected. N24 agreed instead that the types are
distinguished by what an application does, that `Application` stays, that a `ServiceApplication`
derives from it with an `Endpoint` carrying a `url`, and that other derived types are added only as
use cases call for them.

## The proposal

**The application profile defines one node type, `ServiceApplication`, and one capability type,
`Endpoint`.**

1. **`ServiceApplication`** derives from `Application`: an application that provides a service
   across the network. It refines `service` to `Endpoint`. It narrows no requirement, so it keeps
   the `host` requirement `Application` inherits, targeting any platform.
2. **`Endpoint`** derives from `Service` and carries a single, optional `url` in place of its four
   properties. The scheme says how the service is reached, `http`, `grpc` and so on, and the port
   is the one consumers connect to. The host is known only once the service is deployed, so a
   template may give the scheme and port alone, `grpc://:5050`, and the realization publishes the
   full address through the attribute the property reflects. A container port behind the exposed
   one belongs to the realization and travels in `implementation-details`.
3. **`MicroServiceApplication`, `MicroService`, `ServerApplication` and `ServerlessApplication`
   go.** Each is a `ServiceApplication` placed on a particular kind of platform, which the
   template's `host` assignment and the application's `technology` now say. A whole application
   realized as one unit, such as a Helm chart, is a `ServiceApplication` like any of its parts.
4. **`Application` stays**, for software that provides no service across the network, and as the
   parent of derived types added later.
5. **`Service` stays as N11 left it, without properties.** It is the target of `interacts-with` and
   asserts only that another application may interact with this one. `Endpoint` is where a
   contract begins, so software that serves nothing over the network carries the empty `service`
   and no false contract.

```yaml
capability_types:
  Endpoint:
    description: >-
      A service reached over a network, at the address its url gives.
    derived_from: Service
    properties:
      url:
        description: >-
          The URL the service is reached at. Its scheme says how the service
          is reached and its port is the one consumers connect to. Supplied
          with or without a host; the realization populates the full address.
        type: Url
        required: false

node_types:
  ServiceApplication:
    description: >-
      An application that provides a service across the network, reached at
      the address its service capability carries.
    derived_from: Application
    capabilities:
      service:
        type: Endpoint
```

## Where placement goes

A template places an application in its `host` assignment, by naming a platform node or with a
node filter, and a realization is selected by the application's `technology` and `product` and by
what its platform is designated to be (I57). A `ServiceApplication` assigned to a
`ContainerPlatform` with `technology: kubernetes` is realized as Kubernetes resources; the same
type assigned to a `ServerPlatform` is realized as software installed on that server. The type says
what the component is, the assignment says where it runs, and the realization is selected from
both.

The Online Boutique already places every microservice this way: each assigns `host: cluster`, a
`ContainerPlatform` node, and sets `technology: kubernetes`.

## What changes

The `0.2` may break templates, since no compatibility is promised before `1.0`:

- **Templates retype their nodes.** A `MicroService`, `MicroServiceApplication`,
  `ServerApplication` or `ServerlessApplication` becomes a `ServiceApplication`, or an
  `Application` if it serves nothing over the network.
- **An unassigned `host` widens.** A node whose type restricted it to one kind of platform, and
  whose template left `host` to be fulfilled, now accepts any platform. A template relying on the
  restriction assigns `host` or adds a node filter.
- **`Endpoint` assignments change.** `port`, `target-port`, `name` and `protocol` become one `url`,
  and a differing container port moves to `implementation-details`.
- **In the repository:** the Online Boutique keeps `main-endpoint-url.yaml`, retyped, in place of
  the form that assigns `port`; the `microservice` substitution example substitutes
  `ServiceApplication` and reads the container port from `implementation-details`; and the
  application profile README describes the two types instead of the two-axis table.

## Open questions

These are left until a use case needs an answer:

- **Further derived types.** Kubernetes classifies its workloads, and the process control systems
  OPAF models, or network functions classified by what they provide, may call for others.
- **Jobs and scheduled jobs.** Whether a task that runs and terminates belongs in a topology at
  all, or is an operation or a detail of a realization.
- **The name `Service`.** The word suggests a network, which `Endpoint` now carries; a more general
  name for the base capability may read better.

## Decision sought

Adopt items 1 to 5 for the `0.2`: `ServiceApplication` with an `Endpoint` carrying an optional
`url`; the four platform-specific types removed; `Application` and `Service` unchanged; and the
examples and README follow.
