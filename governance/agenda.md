# TOSCA Community — Proposed Agenda (2026-08-05)

**Status:** Draft agenda for 2026-08-05, following 2026-07-22 (no meeting 2026-07-29)
**Related documents:** [README](../profiles/community/tosca/README.md) · [prior-art](../profiles/community/tosca/docs/prior-art.md) · [design-guide](../profiles/community/tosca/docs/design-guide.md) · [profile-naming](../profiles/community/tosca/docs/profile-naming.md) · [kubernetes-modeling](../profiles/community/tosca/docs/kubernetes-modeling.md) · [open-issues](open-issues.md)

Two weeks since the last meeting. Issue references point to
[open-issues.md](open-issues.md).

---

## 1. Action-item review — 10 min

From 2026-07-22:

- **Core data types** (Roberto, *D9*) — ✅ email, FQDN and HTTP URL types **merged**
  into `core`. This cleared the `0.1` gate, which has now been open for two weeks
  (see #3).
- **Kubernetes consolidation** (Chris, *K6 / I21 / I22*) — ✅ **complete**. A single
  Kubernetes resource profile, `io.kubernetes:1.35`; the duplicate under
  `technology/` removed (~12,500 lines); `technology/README.md` now states plainly
  that there is no Kubernetes profile there and points at
  `profiles/io/kubernetes/1.35`. Confirm K6 closed.
- **Abstract-profile platform properties** (Chris, *N8*) — ❌ **not done.** The
  connection properties (management address, credential file, config/access file)
  are still absent from the `abstract.*` types. This has now slipped twice: promised
  at 2026-07-15 for review on 07-22, then re-committed on 07-22. Re-commit with a
  date, or hand it off.
- **Tal's OpenAPI→TOSCA generator** (Roberto) — a submission location was to be
  suggested. Is the PR in, and when do we walk it (see #6)?
- **Kubernetes profile testing** (Prachi, Jay) — feedback was due after their return
  from leave; nothing has reached the repository. Status? (see #5)

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
- Decide whether N8 (#1) blocks the tag or ships in `0.1.1`.

## 4. Design-guide additions — 10 min · *I16 / I17*

Seven commits between 07-27 and 08-04, none of them a standing action item. Worth a
walkthrough, and the last bullet carries a ratification now deferred twice:

- **Component/Port**: the *Data placement* principle — which capability carries a
  value; and *Secrets are references, not values*.
- **Security** split into perimeter / authn / authz / identity, keeping authn and
  authz distinct.
- **Profile organization has two dimensions** — the model continuum crossed with
  platform-versus-application, and the placement rule that follows. Includes a note
  that `profile-organization.png` needs extending to show the application, data and
  network columns below System View.
- **`type-of-node`** resolved, plus placement mechanics.
- **Carry-over:** ratify the *I16 / I17* Component/Port resolutions drafted in
  `design-guide.md`. `open-issues.md` still records these as "Ratify 2026-07-22",
  which did not happen.

## 5. Kubernetes: testing feedback and application-level modeling — 10 min

- First feedback from **Prachi and Jay** on `io.kubernetes:1.35` — gaps and fixes
  needed before broader use.
- Open design question in
  [`kubernetes-modeling.md`](../profiles/community/tosca/docs/kubernetes-modeling.md):
  where **application-level** (microservice-to-microservice) interaction belongs,
  given the substitution boundary and that requirements are declared on types.

## 6. Tal's alternative Kubernetes generation — 5 min

Review where Tal's automated OpenAPI-to-TOSCA approach belongs in the repository and
schedule a PR walkthrough. Multiple modeling approaches stay open.

## 7. Open items & AOB — 10 min

- **OPAS / Margo end-to-end demo** — container-based deployment to edge devices.
  Offered at 07-22 for "a future meeting"; propose a date.
- **Governance docs** — proposal to retire the per-meeting narrative in
  `meeting-history.md` and let `decision-log.md` and `open-issues.md` carry the
  record.
- Single source of truth for shared types (*I1 / I15*); errata (*I5, I7, I13, I14,
  I23*); Windows checkout failure (*I20*); contribution-load / second owners
  (*I11*).

---

**Decisions sought:** the YAML `implementation-details` convention (#2); cut `0.1`
(#3); ratify the Component/Port resolutions (#4).
