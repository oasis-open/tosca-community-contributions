# TOSCA Community — Proposed Agenda (next meeting)

**Status:** Draft agenda for the meeting following M38 (2026-06-24)
**Related documents:** [README](../README.md) · [prior-art](../prior-art.md) · [design-guide](../design-guide.md) · [abstract-profile-proposed-changes](../abstract-profile-proposed-changes.md) · [meeting-history](meeting-history.md) · [decision-log](decision-log.md) · [open-issues](open-issues.md)

Prioritized from the [open-issues tracker](open-issues.md) — carry-overs from
M38, the one newly-surfaced item, and the decisions that are ripe (rather than
touching all open issues). Issue references (I1–I18) point to `open-issues.md`.

---

## 1. Logistics & carry-overs — 5 min
- Confirm the Calin catch-up (M38 action item) happened / schedule it.
- Quick status round.

## 2. Abstract-profile enhancements — Roberto's review — 15 min · *I1*
- M38 decided credential / management-address properties stay **specific to each
  derived platform type** (not harmonized on the base `Platform`); the
  [abstract-profile doc](../abstract-profile-proposed-changes.md) was updated to
  reflect that.
- **Seeking:** Roberto's review feedback (his M38 action item) and a decision on
  whether to open the PR.

## 3. `in_range` signature — 10 min · *I18 (new)*
- `community.tosca.core`'s `in_range` is 3-arg `(value, min, max)`; proposal is
  to match the **TOSCA v1.3** 2-arg `(value, range)` form.
- Surfaced during external (Ubicity) 2.7 release testing, where the signature
  mismatch broke tests.
- **Seeking:** decision + an owner to update the declaration and its callers.

## 4. Release process — 15 min · *I8 (gating item)*
- Concrete motivation: an external ecosystem just cut a **v2.7 release** and had
  to sync several downstream repos against a moving `master` — exactly the
  brittleness I8 describes.
- Revisit the M38 direction: **freeze `0.1`**, then versioning + immutable
  release artifacts (tags / CSARs).
- **Seeking:** agreement on a first concrete step (e.g., tag `0.1`, draft a
  release / compatibility policy).

## 5. Single source of truth for shared types — 10 min · *I1 / I15*
- Should `Credential`, `IPv4Socket`, and shared relationship/capability types be
  owned solely by `community.tosca.core`, with other profiles importing rather
  than redefining them? (Nominal typing makes duplicates incompatible.)
- **Seeking:** direction, contingent on the release-process decision above.

## 6. TOSCA 2.0 -> 2.01 errata status — 5 min · *I5, I7, I13, I14*
- Where the errata list stands; is the TC meeting scheduled? Quick triage — do
  not re-litigate.

## 7. Collaborations & AOB — 5 min · *C1–C4, I11*
- Brazil OPAF / OPAS PoC (August); Swarmchestrate / Westminster.
- Contribution-load / bus-factor (I11): can any open item pick up a second owner?

---

**Decisions sought this meeting:** #2 (open the abstract-profile PR?),
#3 (`in_range` signature), #4 (first release-process step).
