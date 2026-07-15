# TOSCA Community — Proposed Agenda (2026-07-15)

**Status:** Draft agenda for 2026-07-15, following 2026-07-08
**Related documents:** [README](../profiles/community/tosca/README.md) · [prior-art](../profiles/community/tosca/prior-art.md) · [design-guide](../profiles/community/tosca/design-guide.md) · [abstract-profile-proposed-changes](../profiles/community/tosca/abstract-profile-proposed-changes.md) · [meeting-history](meeting-history.md) · [decision-log](decision-log.md) · [open-issues](open-issues.md)

Follows up on the 2026-07-08 action items. Issue references point to
[open-issues.md](open-issues.md); decision references to
[decision-log.md](decision-log.md).

---

## 1. Action-item review — 10 min
- **`in_range` PR — merged** (Roberto, *D8 / I18*, PR #348) — the 2-arg
  `(value, [min, max])` signature landed, plus **`in_range_strict`** (open
  interval) and integer/float/string/timestamp/version overloads. Confirm and
  note the expanded scope.
- **Abstract-profile properties** (Chris, *N8*) — now **unblocked** by the
  `in_range` merge: add the platform connection properties (management address,
  credential file, config/access file) to the community abstract platform types.
- **Release workflow set up** (Chris, *R4 / I8*) — an existing, proven release
  workflow (CSAR build + signing) copied + adapted into the community repo.

## 2. Cut the stable `0.1` release — 15 min · *R3 / R4 / I8* — **the main item**
- The target was a **stable `0.1` of the core profile by this week** — confirm
  it's cut, or what remains.
- Adopt **Sigstore signing + `verify_*.sh` scripts** for the release artifacts?
- Confirm the flat directory + CSAR-naming-from-`profile:` approach holds in
  practice.

## 3. Substituting templates exercising the abstract profiles — 15 min · *K5 / I21*
- Chris's progress on the **Kubernetes substitution template** (exercising the
  abstract platform types).
- Westminster readout — Prachi's example template and the **2026-07-13
  Prachi/Jay deployment** discussion; Prachi's interest in producing profiles
  for her own work (possible separate session).

## 4. Open items & AOB — 10 min
- Single source of truth for shared types (*I1 / I15*); errata (2.01) status
  (*I5, I7, I13, I14*); Windows checkout failure (*I20*); contribution-load /
  second owners (*I11*).

---

**Decisions sought:** confirm/cut the `0.1` release and whether to sign it (#2);
direction for the abstract-profile substitution validation (#3).
