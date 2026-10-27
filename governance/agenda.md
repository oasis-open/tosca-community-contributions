# TOSCA Community — Proposed Agenda (2026-10-28)

**Status:** Draft agenda for 2026-10-28, following 2026-10-21
**Related documents:** [spec-implementation-binding-proposal](../profiles/community/tosca/docs/spec-implementation-binding-proposal.md) · [application-types-proposal](../profiles/community/tosca/docs/application-types-proposal.md) · [Online Boutique](../examples/online_boutique) · [open-issues](open-issues.md) · [decision-log](decision-log.md)

On 10-21 we agreed that the function implementations leave `core` for the `0.2` (D16), and I
undertook to write up how an orchestrator supplies its own without every service template
repeating them. Part 2 is that write-up. Part 3 returns to the `Endpoint` capability with the
`url` option now written into the Online Boutique, and Part 4 is the application node types,
which depend on what Part 3 decides.

---

## Part 1 — Since 10-21 — 5 min · **presentation**

- **The 10-21 record**: D16, the `Endpoint` discussion (I56), the application node types as a new
  issue (I58), and Roberto's comment on the cluster example (I59).
- **The Online Boutique is in the repository in two forms**: Roberto's revision, with `Endpoint`
  as the `0.2` profile defines it, and the same template with a single `url` (Part 3).

---

## Part 2 — Attaching implementations to `core` — 20 min · **first reading** · *I9, I43, I55* · [proposal](../profiles/community/tosca/docs/spec-implementation-binding-proposal.md)

In TOSCA 2.0 a function receives an implementation where it is declared or in a service template,
and an operation in a derived type or a template, and from nothing else. Roberto's concern on
10-21 was the template: with `core` shipping signatures only, every template would repeat
the implementations.

**Proposed:** a TOSCA file that names a profile with a new `implements` keyname may only add
implementations to that profile's definitions, written in the grammar that declared them, with
function signatures given a `name` so that a refinement addresses them by name rather than
position. An orchestrator supplies `core`'s implementations in such a file, and a template
receives them in one of two ways:

- **By import.** The orchestrator's own profile imports the implementing file, and templates
  written for that orchestrator receive the implementations through the imports they already have.
- **By configuration.** The processor is configured with the implementing file, which applies
  wherever `core` is imported, so a template imports `core` and nothing else. This is the
  specification's *"preconfigured to handle the function call"* given a form that can be
  inspected.

`core` stays self-contained: it names nothing it cannot resolve and imports nothing that exists
only per orchestrator. The same file covers operations, which have no refinement site outside a
derived type or a template today. Tal's named implementations from #384 are among the
alternatives, with why the reference runs the other way here.

**Input wanted:** whether this answers the concern; and whether it goes to discussions 365 and 384
and then to the TC, which would have to adopt the grammar.

---

## Part 3 — What `Endpoint` carries — 15 min · **decision sought** · *I56* · [Online Boutique](../examples/online_boutique)

Two options remain from 10-21, the property-free `Endpoint` having been agreed to add nothing over
`Service`:

1. **Remove `Endpoint`**, so that `MicroService` keeps the base `Service`, and both the port and
   the container port travel in `implementation-details`.
2. **Keep `Endpoint` with a single `url`**, as the platform types carry `mgmt-address`.
   [`main-endpoint-url.yaml`](../examples/online_boutique/main-endpoint-url.yaml) shows it: the
   scheme says how a service is reached and the port is the one consumers connect to, so
   `frontend` is `http://:80` and the gRPC services `grpc://:<port>`, with the host left out until
   deployment. Each container port travels as `target-port` in `implementation-details`.

The `url` keeps at the abstract level what is meaningful there, such as where the storefront is
reached, and moves only the container port, which belongs to the realization.

**Decision sought:** which of the two. Roberto then brings the Online Boutique to the chosen form,
and the `microservice` substitution example follows.

---

## Part 4 — The abstract application node types — 15 min · **first reading** · *I58* · [proposal](../profiles/community/tosca/docs/application-types-proposal.md)

Three of the four application types differ only in the platform they accept, which decides
placement in the type, before a realization is selected. Proposed: type an application by what it
does and how it is reached, and leave where it runs to the template's `host` assignment and the
realization's selection.

- No application type narrows `host`.
- `ServiceApplication`, an application that provides a service across the network, replaces
  `ServerApplication` and carries `Endpoint`.
- `MicroService` and `MicroServiceApplication` derive from `ServiceApplication`;
  `ServerlessApplication` derives from `Application`.
- `Service` stays without properties.

It assumes Part 3 keeps `Endpoint`: without it, `ServiceApplication` adds nothing to
`Application`.

**Input wanted:** whether the platform axis goes; whether `MicroService` and
`MicroServiceApplication` should differ; and whether to continue in a GitHub discussion, as
Roberto suggested, so that Tal can take part.

---

## If time permits

- **The cluster example (I59)**: keeping the top level abstract while still showing the
  requirement mapping.
- **What a platform is designated to be (I57)**: D15 has realizations select on a property
  saying what a platform is designated to become, and no platform type carries one. Part 4 relies
  on it.
- **Where examples and substituting templates live (I53)**: Roberto or Stefano to circulate a
  proposal, from 10-07.
- **I44, the relationship kind**: carried until more participants attend. Tal has not been asked.
- **Orchestrated credentials (I27, I41)** and **the artifact calling convention (I10)**.
- **A pinned announcement in Discussions**, deferred on 09-30.

---

**Input wanted (Part 2):** whether implementing files answer the concern of 10-21, and whether
the proposal goes to the discussions and the TC.

**Decision sought (Part 3):** whether `Endpoint` is removed or carries a single `url`.

**Input wanted (Part 4):** whether the application node types stop naming a platform, with
`ServiceApplication` replacing `ServerApplication`.
