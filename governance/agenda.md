# TOSCA Community — Proposed Agenda (2026-08-12)

**Status:** Draft agenda for 2026-08-12, following 2026-08-05
**Related documents:** [README](../profiles/community/tosca/README.md) · [design-guide](../profiles/community/tosca/docs/design-guide.md) · [profile-naming](../profiles/community/tosca/docs/profile-naming.md) · [kubernetes-modeling](../profiles/community/tosca/docs/kubernetes-modeling.md) · [open-issues](open-issues.md) · [decision-log](decision-log.md)

Item 1 is a specification question raised on the `implementation-details` discussion
that bears directly on a decision taken on 08-05; it is taken first, while the group
is fresh and the decision is still open. Item 2 is a **live demonstration** of
substitution-driven realization against a real device estate, and it shows in
working form much of what item 1 discusses. Issue references point to
[open-issues.md](open-issues.md).

---

## 1. Must every substituting-template input be mapped? — 15 min · *raised by Roberto* · **decision sought**

Roberto has reopened the `implementation-details` discussion
([#258](https://github.com/oasis-open/tosca-community-contributions/discussions/258))
with a specification question; the reasoning below is posted there in full, so the
meeting can start from a written position rather than from cold. §15.2 says only:

> Property mappings must be defined for all non-optional service template inputs that
> do not define a `default` value.

That wording is narrower than "every input of a substituting template must be mapped
from a property of the substituted node." On a plain reading, a substituting template
may declare **additional inputs that are not mapped at all**, provided they are
optional or carry a default — which would mean `implementation-details` is not the
only way for a substituting template to obtain implementation-specific information.

Roberto's three readings:

1. **Implementation-specific** — the standard permits unmapped inputs and each
   orchestrator decides how they resolve (default, prompt, orchestrator API, …).
   Maximum flexibility, least portability.
2. **Restrictive** — unmapped inputs are allowed only where the substituting template
   stays valid with no external intervention; every required input without a default
   must be mapped. Closest to the literal wording.
3. **Community best practice** — even where the specification permits unmapped inputs,
   recommend that all inputs derive from the substituted node's interface, with an
   opaque property the preferred carrier when implementation-specific information is
   needed. No normative change; a recommendation.

**The case the three options miss.** An abstract node hides detail — that is what
makes it abstract. But the substituting service frequently *needs* some of what was
hidden, and needs it **per substituted node**. An unmapped input with a default cannot
supply that: a default is fixed when the realization is authored, so it can only ever
carry a lowest-common-denominator value, never the value *this* node requires. So
options 1 and 2 do not stand in for `implementation-details` — they cover only inputs
whose value is genuinely constant across every use of the realization. The moment a
value varies with the node being substituted, it has to arrive **through** the
substitution interface, and mapping is the only mechanism that crosses it.

That reframes the question. It is not really *may* unmapped inputs exist — on the
wording, they may. It is **what carries per-instance implementation detail across the
boundary**, and for that there is no alternative to a mapped property. Chapter 15's own
framing points the same way: substitution "allows for simplified representations of
complex systems that *abstract away* technology or vendor-specific implementation
details" — abstracting a detail away at the top implies a way to reintroduce it at the
bottom.

This bears directly on **D10** (agreed 08-05), which adopted the YAML-encoded
`implementation-details` property. D10 survives either way, but its justification
changes: not "the only legal route" but "the only route that carries a value which
varies per node."

**Decision sought:** which reading the community adopts, and whether the answer is a
best-practice note in the design guide, an errata question for the TC, or both. The
question back to the group — was the possibility of additional unmapped inputs left
open deliberately, and if so, is the wording of §15.2 clear enough that a reader will
not mistake a default for a substitute for mapping?

## 2. Demonstration — one abstract topology, two realizations — 30 min

A live run of an integration between a TOSCA orchestrator and **Margo**, the
edge-management project, shown as a working system rather than as slides.

**The claim.** One vendor-neutral OPAS topology, naming no technology, is realized
onto **two different delegate runtimes at once** — Margo for one device, a container
realization for another — and an application placed by *where it belongs in the plant*
reaches a concrete machine across **two substitution boundaries**. The point is
coexistence: a delegate runtime is one realization among several beneath a single
abstract service template, not a replacement for the orchestration layer above it.

**What is worth watching, for this audience.** The interesting part is not that the
abstract node was realized, but **how the orchestrator decided which realization**,
and what the grammar for saying so looks like:

- `directives: [substitute]` on an abstractly-typed node, and a realization's
  `substitution_filter` matching on **manufacturer and model together**. Two
  realizations differing only in model is the case that shows why manufacturer alone
  is not enough.
- `substituted_by` on the abstract node, and **attribute escalation across the
  substitution boundary** — a value discovered on the device, readable at the abstract
  layer. This is the part most people have not seen.
- A realization whose filter **traverses to the device it is hosted on**
  (`[SELF, RELATIONSHIP, Host, 0, TARGET, …]`) rather than reading anything about the
  application itself. Selection follows placement, and the explicit keyword path is
  what makes it expressible.
- **Cross-service requirement matching** — requirements left dangling in one service
  and matched against a *different* service at deploy time.

**The distinction the demo argues.** Node operations are automation; relationship
`Configure` operations at their weave points are orchestration. Worth naming
explicitly, since it is the difference between this and a deployment tool.

**Discussion sought:** whether the modelling patterns above are ones the community
wants to write down — the substitution-filter idioms in particular, which are close
to the placement mechanics already drafted in the design guide.

## 3. The `0.1` release — 10 min · *I8 / I26 / N8*

Two things stand between us and the tag, and neither has moved since 08-05:

- **N8 — platform connection properties.** Still absent from the `abstract.*` types.
  Sequenced behind **D11** (the credential model: a map keyed by kind, each value a
  reference to where the credential is retrieved, never the value itself). Is the D11
  write-up posted to #281, and does the sequence still hold — or do we ship `0.1`
  without the connection properties and follow with a `0.1.1`?
- **I26 — `HttpUrl` is not anchored at the end.** Unlike `Email` and `Fqdn`, which both
  end with `$`, `HttpUrl` stops after the host and optional port, so everything after
  that is unvalidated: `https://example.com garbage here`, a trailing newline with
  further text, `https://example.com:99999`, and `http://999.999.999.999` all pass.
  Appending `$` is **not** the fix — that would reject `https://example.com/path?q=1`,
  which legitimately passes today. `core` ships in the `0.1`, so this is worth fixing
  before the tag.

  Second question behind it: `core` is now the community's standard library, so should
  its data types carry **test cases**? A regex library without tests will drift again.

The repository still carries **no tags**. Once the above is settled: push `v0.1` → the
workflow builds and signs, opens a draft → review and publish.

---

## 4. Action-item review — *if time permits*

- **Kubernetes profile testing** (Prachi, Jay) — feedback on `io.kubernetes:1.35`;
  nothing has reached the repository yet.
- **Tal's OpenAPI→TOSCA generator** — no PR is open yet; where it belongs in the
  repository, and a date to walk it.
- **D10 applied** — the `YAML` type and the `decode_yaml` / `validate_yaml` pair are in
  `core`, all six `implementation-details` declarations in `abstract.base` are
  `type: YAML`, and the base README records why. Confirm closed, subject to #2.

## 5. Design-guide walkthrough — *if time permits*

Carried from 08-05. Component/Port *Data placement* and *Secrets are references, not
values*; the security split into perimeter / authn / authz / identity; profile
organization's two dimensions; placement mechanics; filters and missing values; and the
proposed resolution for `type-of-node` (*I13*) — recommending **not** adding a
type-returning function, since platforms of the same type that differ only in what each
is designated to become cannot be distinguished by type at all.

## 6. Open items & AOB — *if time permits*

- **I25 — monitoring and telemetry escalation.** The *bottom-up* counterpart to
  top-down refinement: low-level monitoring data summarized into high-level
  system-health attributes, via `substitution_mappings.attributes`. Needs a written
  pattern. The demo (#2) exercises attribute escalation, so there is a worked example
  to draw on.
- **I24 — union types**, of which the credential model is one instance.
- **Governance docs** — proposal to stop adding per-meeting entries to
  `meeting-history.md` and let `decision-log.md` and `open-issues.md` carry the record.
- Kubernetes application-level modeling (where microservice-to-microservice interaction
  belongs); single source of truth for shared types (*I1 / I15*); errata (*I5, I7, I14,
  I23*); Windows checkout failure (*I20*); contribution load and second owners (*I11*).

---

**Decisions sought:** the reading of §15.2 on unmapped substituting-template inputs, and
where the answer is written down (#1); confirm the N8 sequence or ship `0.1` without it,
and fix `HttpUrl` before the tag (#3).
