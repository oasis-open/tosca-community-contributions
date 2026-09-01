# Two Amendments to TOSCA v2.0 §1.2.2

**Status:** Draft — not submitted.
**Audience:** OASIS TOSCA Technical Committee. Unlike the other documents here, this one
addresses the specification rather than the community profiles.
**Purpose:** Propose two changes to §1.2.2 *TOSCA Naming Conventions* — permit snake case for
value names, and make the acronym rule context-free by keeping acronyms upper throughout.
**Normative impact:** None. §1.2.2 already states that parsers should not enforce these
conventions and that authors are free to differ.

**Related documents:** [design-guide](design-guide.md) · [profile-naming](profile-naming.md) ·
[abstract-profile-proposed-changes](abstract-profile-proposed-changes.md)

---

TOSCA v2.0 prefers dash case for value names, and treats an acronym one way alone and another
way in company. Neither rule is carrying its weight, and one of them is being ignored almost
everywhere.

## What is being asked

1. **Permit snake case for value names**, alongside dash case, consistent within a profile —
   and withdraw the stated rationale that dash case exists to distinguish value names from
   keynames.
2. **Make the acronym rule context-free**, keeping acronyms upper throughout — `HTTPEndpoint`,
   `TCPOrUDP`, `TCP`, `DBMS` — so an acronym is spelled the same way whether or not other words
   join it.

No change is proposed to CamelCase for entity type names. That rule draws the one distinction a
reader cannot recover from position, and it should stay exactly as it is.

## What the specification says today

§1.2.2 sets out five conventions: snake case for keynames, dash case for value names, CamelCase
for entity types, lower-case whole words for primitive data types, and snake case for functions.

The rule at issue is stated with its reasoning attached:

> *TOSCA value names*: dash case (also called kebab case). This includes names of node templates,
> properties, attributes, inputs, operations, capabilities, relationships, metadata keys,
> repository names, artifacts names, etc. **Dash case is preferred in order to differentiate
> these names from keynames.**

## 1. The rationale for dash case does not hold

### Keynames and value names never compete for a position

A reader knows `properties` is a keyname because of where it sits in the grammar, not because of
how it is spelled. There is no position in a TOSCA document where a keyname and a value name
could be mistaken for one another, and no parser needs the distinction. The convention pays a
cost to disambiguate something already unambiguous.

### The cost is paid where TOSCA's value proposition is

The purpose of the language is that modelled values reach implementations. A property named
`mgmt-address` is not a legal shell variable, not a Python identifier, and not a Go struct
field. Every artifact and every SDK must transliterate it, and transliteration is ambiguous in
both directions: `mgmt_address` could have come from either spelling. Snake case is a legal
identifier in very nearly every host language, which is why authors reach for it precisely where
a name has to cross into code.

### The convention is not being followed

Property and attribute names counted across three independently authored profile families — the
TOSCA community profiles, the Ubicity profiles, and the O-PAS Part 9 profiles:

| Profile family | dash | snake | CamelCase | one word | total |
|---|---:|---:|---:|---:|---:|
| TOSCA community | 9 | 20 | 0 | 31 | 60 |
| Ubicity | 2 | 101 | 0 | 101 | 204 |
| O-PAS Part 9 | 0 | 54 | 85 | 40 | 179 |
| **All three** | **11** | **175** | **85** | **172** | **443** |

The 85 CamelCase names are O-PAS profiles mirroring the PascalCase of the O-PAS Part 9 schema,
so they are not free choices. Excluding them leaves 358 names chosen by an author, of which 11
use the preferred convention.

Four distinct dash-case names exist across all three families — `implementation-details`,
`ip-address`, `target-port`, `transport-port` — and a fifth, `mgmt-address`, in the Ubicity
profiles alone.

The sharpest measure is operation inputs, where a name must become a variable inside a script.
Across the same profiles there are **143 declared operation inputs and not one uses dash case**:
80 snake case, 63 single words. Authors are not rejecting the convention on taste; they abandon
it at exactly the boundary where it stops working.

### What this proposes

Permit either separator for value names, consistent within a profile, and remove the
differentiation rationale. The remaining conventions then collapse into two a reader can hold:
**CamelCase for entity types, lower case with a separator for everything else.** It also brings
the guidance into agreement with what the ecosystem already writes, rather than leaving a rule
that documents its own non-adoption.

## 2. The acronym rule changes an acronym's spelling based on its neighbours

> Acronyms and abbreviations should be treated as words, *except* when the name is just a single
> acronym. Examples: "HttpEndpoint", "TcpOrUdp", "TCP", "DBMS".

The same acronym is spelled two ways depending on what sits beside it — `TCP` alone, `Tcp` in
company. Three consequences follow:

- An author cannot decide how to spell an acronym until the whole name is settled, so the rule
  cannot be applied incrementally.
- Adding a word to a type name silently respells a part of it that did not change: `TCP`
  becoming `TcpOrUdp` is not an extension, it is a rename.
- A reader searching for `TCP` does not find `TcpOrUdp`, and nothing signals that they are the
  same term.

Comparable style rules elsewhere are context-free in one direction or the other. Go keeps
acronyms upper throughout (`HTTPServer`, `URL`); .NET uppercases two-letter acronyms and treats
longer ones as words. Either is defensible. What is hard to defend is a rule whose output
depends on the rest of the name.

### The rule that is followed is not the rule that is written

Type names containing an acronym were counted across the same three profile families:

| | count | examples |
|---|---:|---|
| Lone acronym, upper | 10 | `DBMS`, `DCN`, `JSON`, `OCF`, `UUID`, `VLAN`, `YAML` |
| Compound, acronym kept **upper** | 24 | `IOChannelConfigurations`, `IPv4`, `DBaaS`, `DCN_IO`, `IOServiceEngine` |
| Compound, acronym written as a word | 5 | `ApiData`, `HttpUrl`, `AlphanumericId`, `GenericId` |

The specification asks for the third row and authors write the second, by nearly five to one.
As with dash case, the convention that exists on paper is not the one in the profiles.

### What this proposes

**Keep acronyms upper throughout**, unconditionally: `HTTPEndpoint`, `TCPOrUDP`, `TCP`,
`DBMS`. Four reasons.

- **It is what authors already do**, by the count above.
- **It keeps the acronym searchable.** An acronym appears identically wherever it occurs, so a
  reader looking for `TCP` finds every name containing it. Under the word form, `TCP` becomes
  `Tcp` in compounds and the search fails — which is the defect this amendment exists to fix.
  Choosing the word form would fix the inconsistency while leaving the search problem in place.
- **An acronym is not a word.** `Dbms` and `Http` assert a pronunciation that nobody uses.
  Capitalizing them as though they were words makes the name harder to read aloud, not easier.
- **It preserves the specification's own examples.** `TCP` and `DBMS` are already written that
  way in §1.2.2, and OASIS specification prose capitalizes acronyms throughout. The word form
  would require changing those to `Tcp` and `Dbms`.

**The honest cost.** Consecutive acronyms run together: `HTTPSURL` is worse than `HttpsUrl`.
This is why .NET uppercases two-letter acronyms and treats longer ones as words. It is a real
edge case and it is rare — no name in the three profile families hits it — and paying it buys a
rule with no exceptions, which is the entire point of the amendment. A profile that finds itself
with two adjacent acronyms should reword the name.

## 3. What is not proposed

**CamelCase for entity type names stays.** Whether a name denotes a type or an instance is the
one distinction a reader cannot recover from position, and a visual cue earns its cost there.
Nearly every language draws it the same way, and the rule is followed in practice.

**Snake case for keynames and functions stays**, and so do lower-case whole words for primitive
types.

**Nothing about conformance changes.** No document becomes valid or invalid, no implementation
changes, and no existing profile needs editing. What changes is what the specification advises —
which is an argument for correcting it rather than leaving guidance the ecosystem has quietly
set aside.

## Method

Every `properties` and `attributes` key was collected from the `node_types`,
`capability_types`, `relationship_types` and `data_types` of each profile, then classified by
whether the name contains a hyphen, an underscore, an initial capital, or none of these:

```python
k = "dash"  if "-" in name else \
    "snake" if "_" in name else \
    "Camel" if name[:1].isupper() else "word"
```

Machine-generated profiles were excluded throughout — Kubernetes, Redfish, 3GPP and OpenConfig
take their names from an external schema and say nothing about what an author would choose. One
imported prior-art file in the community repository was excluded for the same reason. Counts are
of declarations, not of occurrences in templates.
