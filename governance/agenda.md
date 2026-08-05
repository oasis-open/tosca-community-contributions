# TOSCA Community — Proposed Agenda (2026-08-05)

**Status:** Draft agenda for 2026-08-05, following 2026-07-22 (no meeting 2026-07-29)
**Related documents:** [README](../profiles/community/tosca/README.md) · [prior-art](../profiles/community/tosca/docs/prior-art.md) · [design-guide](../profiles/community/tosca/docs/design-guide.md) · [profile-naming](../profiles/community/tosca/docs/profile-naming.md) · [kubernetes-modeling](../profiles/community/tosca/docs/kubernetes-modeling.md) · [open-issues](open-issues.md)

Two weeks since the last meeting, so there is more to cover than usual. Items 1–7
carry the decisions; items 8–11 are marked *if time permits*. Issue references point
to [open-issues.md](open-issues.md).

---

## 1. Action-item review — 10 min

From 2026-07-22:

- **Core data types** (Roberto, *D9*) — ✅ email, FQDN and HTTP URL types merged into
  `core` (PR #354). This cleared the `0.1` gate, which has now been open for two
  weeks (see #3).
- **Kubernetes consolidation** (Chris, *K6 / I21 / I22*) — ✅ **complete**. A single
  Kubernetes resource profile, `io.kubernetes:1.35`; the duplicate under
  `technology/` removed (~12,500 lines); `technology/README.md` now states plainly
  that there is no Kubernetes profile there and points at
  `profiles/io/kubernetes/1.35`. Confirm K6 closed.
- **Abstract-profile platform properties** (Chris, *N8*) — **awaiting the credential
  resolution (#4).** The connection properties (management address, credential file,
  config/access file) are still absent from the `abstract.*` types. One of the three
  *is* a credential, so its shape depends on what #4 settles — adding it now would
  mean adding it twice. Sequence N8 behind #4 rather than re-committing to a date for
  it here.
- **Tal's OpenAPI→TOSCA generator** (Roberto) — a submission location was to be
  suggested. Is the PR in, and when do we walk it (see #10)?
- **Kubernetes profile testing** (Prachi, Jay) — feedback was due after their return
  from leave; nothing has reached the repository. Status? (see #7)

## 2. `implementation-details` as YAML — 10 min · **decide before #3**

A change the community has not yet reviewed: `implementation-details` is now encoded
as **YAML rather than JSON**, with new `decode_yaml` / `validate_yaml` functions in
`core` and a stated parser dependency.

This reverses a convention the group adopted earlier, and it touches **both profiles
that make up the `0.1` release**. Ratify it, amend it, or hold it back — but decide
before cutting the tag, so the release does not ship a convention change the
community has not reviewed.

## 3. Cut the `0.1` release — 15 min · *R1 / R3 / R4 / R5 / I8*

- Scope is unchanged: `core` + the five `abstract.*` profiles; technology profiles
  held (R5).
- The D9 gate cleared on 07-22 (PR #354) and the repository still carries **no
  tags**. Nothing is blocking this except #2.
- Push `v0.1` → the workflow builds and signs, opens a draft → review and publish.
- N8 (#1) waits on the credential resolution (#4), so `0.1` ships without it. Confirm
  that, and whether the platform connection properties then warrant a `0.1.1`.

## 4. Credential model — 10 min · *discussion #281* · **decision sought**

A full design of record for credentials has been written up and is ready to bring
back to #281. It adopts the discussion's synthesis — a minimal data type plus
technology-specific typed nodes — and extends it to the **capability** (the same shape
on the port) and to **multiplicity**.

The substantive refinement concerns the discussion's later revision, which moved from
a map to a **list of `{name, type, file}` entries** to admit same-kind duplicates. The
proposal is to keep the **map keyed by kind**, on a language constraint rather than a
preference:

- A TOSCA path indexes a **map by key** and a **list by integer position**, and there
  is no predicate form. Against a list of typed entries, *"the entry whose `type` is
  `ssh`"* is **not expressible in `$get_property` at all** — retrieval would need a
  custom function or a positional convention, either of which puts the kind→entry
  mapping somewhere the model cannot see.
- With a map, the entry needs no `type` field, because **the key is the type**.
- Same-kind multiplicity is rare inline and belongs at node cardinality; the list
  survives only as the map's *value* (`map<kind, list<Credential>>`) for the narrow
  case where one node must hold same-kind duplicates.
- The `kind` vocabulary is constrained with `key_schema` + `$valid_values`.

**Decision sought:** take this refinement back to #281 as the proposed resolution.

## 5. `type-of-node` — proposed resolution — 5 min · *I13* · **decision sought**

Recommend **not** adding a type-returning function, on the grounds that property-based
selection is strictly more general:

- Platforms of **different types** can be distinguished either way, since a distinct
  type can also expose a property saying what it is.
- Platforms of the **same type** cannot be distinguished by type at all — a fleet of
  like devices differing only in what each is designated to become is one node type
  with different property values, and a type-returning function would find them
  identical. This case is common.

A property filter covers both cases; a type filter covers one. It does place a
requirement on the platform representation: it must carry a property saying what the
platform is **designated to be**, which the platform-representation list in the design
guide does not yet call out — location, capabilities, capacity and access describe
what a platform *is and can do*, not what it is *for*.

Consistent with the direction already recorded for I4.

**Decision sought:** accept the resolution and close I13; add the designation property
to the platform-representation list.

## 6. Component/Port modeling resolutions — 10 min · *I16 / I17* · **decision sought**

Carry-over, now deferred twice. `open-issues.md` still records these as "Ratify
2026-07-22", which did not happen. Ratify the resolutions drafted in
`design-guide.md`: intent-based relationship naming; where to declare the
capability↔relationship constraint; and the formalized monitoring and security
patterns.

## 7. Kubernetes profile testing feedback — 5 min

First feedback from **Prachi and Jay** on `io.kubernetes:1.35` — gaps and fixes needed
before broader use.

---

## 8. Design-guide walkthrough — *if time permits*

Seven commits between 07-27 and 08-04, beyond the I13 resolution at #5:

- **Component/Port**: the *Data placement* principle — which capability carries a
  value; and *Secrets are references, not values*.
- **Security** split into perimeter / authn / authz / identity, keeping
  authentication and authorization distinct.
- **Profile organization has two dimensions** — the model continuum crossed with
  platform-versus-application, and the placement rule that follows. Both dimensions
  are already in the guide; what is new is crossing them below the System View level.
  Notes that `profile-organization.png` needs extending to show the application, data
  and network columns at the lower two levels.
- **Placement mechanics** — the capability determines which platforms are eligible and
  the node filter chooses among them; a filter may be declared on both the requirement
  definition and the assignment, and both apply, so a template can narrow what its
  type permits but never relax it.
- **Filters and missing values** — TOSCA's three-valued comparison semantics, and an
  asymmetry worth knowing: a **node filter** that evaluates to null lets the candidate
  **pass**, while a **substitution filter** that evaluates to null means the template
  **does not match**. Placement is permissive about what it does not know; realization
  selection is not.

## 9. Kubernetes application-level modeling — *if time permits*

Open design question in
[`kubernetes-modeling.md`](../profiles/community/tosca/docs/kubernetes-modeling.md):
where **application-level** (microservice-to-microservice) interaction belongs, given
the substitution boundary and that requirements are declared on types.

## 10. Tal's alternative Kubernetes generation — *if time permits*

Review where Tal's automated OpenAPI-to-TOSCA approach belongs in the repository and
schedule a PR walkthrough. Multiple modeling approaches stay open.

## 11. Open items & AOB — *if time permits*

- **New issue to open — monitoring and telemetry escalation.** The design guide now
  notes the *bottom-up* counterpart to top-down refinement: low-level monitoring data
  summarized and aggregated into high-level system-health attributes. The mechanism
  already exists — `substitution_mappings.attributes` escalates values from a
  substituting service onto the substituted node — but it needs an issue number and a
  written pattern.
- **OPAS / Margo end-to-end demo** — container-based deployment to edge devices.
  Offered at 07-22 for "a future meeting"; propose a date.
- **Governance docs** — proposal to stop adding per-meeting entries to
  `meeting-history.md` and let `decision-log.md` and `open-issues.md` carry the
  record. The historical synthesis stays: `decision-log.md` and `open-issues.md`
  reference meeting numbers 51 times, and the phase narrative is what resolves them.
- Single source of truth for shared types (*I1 / I15*); errata (*I5, I7, I14, I23*);
  Windows checkout failure (*I20*); contribution-load / second owners (*I11*).

---

**Decisions sought:** the YAML `implementation-details` convention (#2); cut `0.1`
(#3); the credential-model refinement for #281 (#4); the `type-of-node` resolution
(#5); ratify the Component/Port resolutions (#6).
