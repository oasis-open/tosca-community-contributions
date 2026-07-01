# TOSCA Community — Agenda (Wednesday, July 1, 2026)

**Status:** Agenda as sent for the meeting following M38 (2026-06-24)
**When:** Wed July 1, 2026 — 5:00pm CET · 4:00pm UK · 8:00am US Pacific · 10:00am US Central *(Zoom link in the meeting invite)*
**Related documents:** [README](../README.md) · [prior-art](../prior-art.md) · [design-guide](../design-guide.md) · [abstract-profile-proposed-changes](../abstract-profile-proposed-changes.md) · [meeting-history](meeting-history.md) · [decision-log](decision-log.md) · [open-issues](open-issues.md)

This week focuses on three items. Issue references (I1, I8, I18) point to
[open-issues.md](open-issues.md).

---

## 1. Abstract-profile enhancements · *I1*
- During last week's meeting we decided that credential / management-address
  properties stay **specific to each derived platform type** (not harmonized on
  the base `Platform`); the
  [abstract-profile doc](../abstract-profile-proposed-changes.md) was updated to
  reflect that.
- **Seeking:** feedback and a decision on whether to open the PR.

## 2. `in_range` signature · *I18*
- `community.tosca.core`'s `in_range` is 3-arg `(value, min, max)`; proposal is
  to match the **TOSCA v1.3** 2-arg `(value, range)` form, to simplify upgrading
  from v1.3 to v2.0.
- **Seeking:** decision + an owner to update the declaration and its callers.

## 3. Release process · *I8*
- Concrete motivation: external profiles currently have to sync downstream repos
  against a moving `master`. We should consider **freezing `0.1`**, then
  versioning + immutable release artifacts. This may require **version-specific
  subdirectories**.
- **Seeking:** agreement on a first concrete step (e.g., tag `0.1`, draft a
  release / compatibility policy).
