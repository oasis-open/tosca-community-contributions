# TOSCA Community — Proposed Agenda (2026-08-12)

**Status:** Draft agenda for 2026-08-12, following 2026-08-05
**Related documents:** [README](../profiles/community/tosca/README.md) · [prior-art](../profiles/community/tosca/docs/prior-art.md) · [design-guide](../profiles/community/tosca/docs/design-guide.md) · [profile-naming](../profiles/community/tosca/docs/profile-naming.md) · [kubernetes-modeling](../profiles/community/tosca/docs/kubernetes-modeling.md) · [open-issues](open-issues.md)

The `0.1` is now gated on the credential/connection-property work agreed on 08-05
(D11 → N8). Items 1–4 carry the decisions; 5–8 are marked *if time permits*. Issue
references point to [open-issues.md](open-issues.md).

---

## 1. Action-item review — 10 min

From 2026-08-05:

- **`implementation-details` as YAML** (*D10*) — ✅ agreed and applied. The `YAML`
  type and the `decode_yaml` / `validate_yaml` pair are in `core`, all six
  `implementation-details` declarations in `abstract.base` are `type: YAML`, and the
  base README documents why YAML rather than JSON. Confirm D10 closed.
- **Credential model** (*D11*) — a map keyed by kind was agreed for write-up in
  discussion #281. Is it posted, and has anyone pushed back?
- **Platform connection properties** (*N8*) — sequenced behind D11 and now the
  remaining `0.1` gate (*I8*). Status of the PR against the abstract profiles.
- **Tal's OpenAPI→TOSCA generator** — is the PR in, and when do we walk it (see #7)?
- **Kubernetes profile testing** (Prachi, Jay) — feedback on `io.kubernetes:1.35`;
  nothing has reached the repository yet (see #4).

## 2. Defect in the new `core` data types — 10 min · *I26* · **decide before #3**

`HttpUrl` (merged in PR #354) is **not anchored at the end**, unlike its two
siblings `Email` and `Fqdn`, which both end with `$`. Everything after the host and
optional port is therefore unvalidated, and the type accepts:

| value | current result |
|---|---|
| `https://example.com garbage here` | accepted |
| `https://example.com` + newline + more text | accepted |
| `https://example.com:99999` | accepted (port above 65535) |
| `http://999.999.999.999` | accepted (matches the FQDN branch) |

The fix is not simply appending `$` — that would reject `https://example.com/path?q=1`,
which legitimately passes today. It needs an optional path/query/fragment component
before the anchor (e.g. `(/[^\s]*)?$`), or a documented decision that the type
validates the authority only.

Two questions for the group:

1. Fix `HttpUrl` before the `0.1`, so the release does not ship a validator that
   accepts arbitrary trailing text.
2. Should `core` data types carry **test cases** in `tests/`? `core` is now the
   community's standard library (confirmed 08-05), and a regex library without tests
   will drift again.

## 3. Cut the `0.1` release — 15 min · *R1 / R3 / R4 / R5 / I8*

- Scope unchanged: `core` + the five `abstract.*` profiles; technology profiles held
  (R5).
- The remaining gate is N8 (#1), which is sequenced behind D11. Confirm the sequence
  still holds, or decide to ship `0.1` without the connection properties and follow
  with a `0.1.1`.
- The repository still carries **no tags**. Push `v0.1` → the workflow builds and
  signs, opens a draft → review and publish.
- Fold the `HttpUrl` fix (#2) in before the tag.

## 4. Kubernetes profile testing feedback — 5 min

First feedback from **Prachi and Jay** on `io.kubernetes:1.35` — gaps and fixes
needed before broader use.

---

## 5. Design-guide walkthrough — *if time permits*

Carried from 08-05. Component/Port *Data placement* and *Secrets are references, not
values*; the security split into perimeter / authn / authz / identity; profile
organization's two dimensions; placement mechanics; filters and missing values; and
the proposed resolution for `type-of-node` (*I13*) — recommending **not** adding a
type-returning function, since platforms of the same type that differ only in what
each is designated to become cannot be distinguished by type at all.

## 6. Kubernetes application-level modeling — *if time permits*

Open design question in
[`kubernetes-modeling.md`](../profiles/community/tosca/docs/kubernetes-modeling.md):
where **application-level** (microservice-to-microservice) interaction belongs, given
the substitution boundary and that requirements are declared on types.

## 7. Tal's alternative Kubernetes generation — *if time permits*

Where Tal's automated OpenAPI-to-TOSCA approach belongs in the repository, and a date
for the PR walkthrough. Multiple modeling approaches stay open.

## 8. Open items & AOB — *if time permits*

- **New issue to open — monitoring and telemetry escalation.** The *bottom-up*
  counterpart to top-down refinement: low-level monitoring data summarized and
  aggregated into high-level system-health attributes. The mechanism already exists
  (`substitution_mappings.attributes` escalates values from a substituting service
  onto the substituted node) but it needs an issue number and a written pattern.
- **OPAS / Margo end-to-end demo** — container-based deployment to edge devices.
  Offered at 07-22 for a future meeting; propose a date.
- **Governance docs** — proposal to stop adding per-meeting entries to
  `meeting-history.md` and let `decision-log.md` and `open-issues.md` carry the
  record.
- Single source of truth for shared types (*I1 / I15*); errata (*I5, I7, I14, I23*);
  Windows checkout failure (*I20*); contribution-load / second owners (*I11*).

---

**Decisions sought:** fix `HttpUrl` before the release, and whether `core` data types
get test cases (#2, *I26*); confirm the N8 sequence or ship without it (#3).
