# Versioning the community profiles

**Status:** Adopted 2026-09-30 (P8).
**Audience:** TOSCA Community.
**Purpose:** State when a profile's version changes, what a version means to someone importing it,
and what the community promises across versions. Decisions R1 to R6 settled how a release is built
and cut; I8 recorded that the rule for the version strings themselves was never written, which
is what this document does.

**Related documents:** [decision-log](../../../../governance/decision-log.md) ·
[open-issues](../../../../governance/open-issues.md) ·
[profile-organization](profile-organization.md)

*Drafted with an AI assistant (Claude).*

---

## The problem

A profile advertises its name and version in one string, and a template imports that string:

```yaml
profile: community.tosca.core:0.2
```

```yaml
imports:
  - profile: community.tosca.core:0.2
```

Nothing else identifies the profile, so the version string is the whole contract between a profile
and the templates that import it. Two consequences followed from that, and the rules below
settle both.

**A released version and the work after it carried the same name.** `0.1` was tagged on
2026-09-29 and published as six signed CSARs, and every profile on `master` still said `0.1`, so a
template importing `community.tosca.core:0.1` resolved to the released CSAR for one consumer and to
whatever had been merged since for another. The CSARs are immutable; the name was not. Rule 1 is
what removes that, and the bump it calls for was made on 2026-09-30.

**A git tag and a profile version are different things.** The release workflow builds a CSAR per
profile and names each from the `profile:` keyword, not from the tag, so a tag alone does not
change what a profile calls itself. Opening the next version means editing those strings.

## Proposal

### 1. The version on `master` is the version being worked on, never a released one

Immediately after a release is cut, every profile's version is raised to the next one. From that
moment `master` says `0.2`, and `0.1` means the published artifacts and nothing else.

A consumer then has two honest choices: import a released version, and get exactly what was
released, or track `master` and know the version is in progress.

### 2. All community profiles carry one version, and it moves together

The seven profiles are released as a set, they import one another, and a consumer reasons about
the set rather than about six independent version lines. A version bump raises all of them, including
profiles unchanged since the last release.

The cost is a version bump that says nothing about whether a given profile changed. The benefit is
that a consumer can state which release it is built against in one string, and that no combination
of versions exists that was never released together.

### 3. What a version promises

- **Within a release, nothing changes.** A published CSAR is immutable; a correction is a new
  version, never an edited artifact.
- **Before `1.0`, no compatibility is promised across versions.** A `0.x` release may rename or
  remove a type, a property or a requirement. This is what the `0.1` release notes say.
- **From `1.0`, a version that adds and does not remove is a minor version**; anything that renames
  or removes is a major one. The community should adopt this at `1.0` rather than now, when the
  profiles are still moving.

### 4. Patch versions exist for corrections, and the import must match

`0.1.1` is a correction to `0.1` that adds nothing. Whether a template importing `0.1` also accepts
`0.1.1`, or whether the two are distinct strings that must match exactly, is a question about TOSCA
rather than about this repository: the specification defines the import as a name and version, and
nominal matching is what a processor implements today. Until that is settled, the community should
publish only two-part versions, `0.1`, `0.2`, and treat a correction as the next of those.

This is the question Roberto raised on 2026-09-16, whether an import of `0.1` matches a profile
named `0.1.0`. The answer proposed here is to avoid the case rather than to rely on an
interpretation.

### 5. The release records the version it published

The decision log already records each release. What it should also record, in one line per release,
is which profile versions that release published, so that the mapping from a tag to a set of
version strings is written down rather than recoverable only from the artifacts.

## What was decided

Adopted at the 2026-09-30 meeting (P8), with rule 4 accepted for now: the community publishes
two-part versions only, and the matching question goes to the TC if anyone needs three-part ones.

The seven profiles were raised to `0.2` the same day, along with everything in this repository that
imports them: the profiles' own imports, the `io.kubernetes` copy, the examples, and the
documentation that names a version.

**A consumer that imports a released CSAR is unaffected by the bump and should not follow it.** The
released `0.1` artifacts keep the name they were published under, so a template importing
`community.tosca.core:0.1` continues to resolve to them. Only a consumer building from a checkout
of `master` moves to `0.2`.
