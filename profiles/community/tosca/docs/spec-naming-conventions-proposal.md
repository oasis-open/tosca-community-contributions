# Three Amendments to TOSCA v2.0 §1.2.2

**Status:** Draft — not submitted.
**Audience:** OASIS TOSCA Technical Committee. Unlike the other documents here, this one
addresses the specification rather than the community profiles.
**Purpose:** Propose three changes to §1.2.2 *TOSCA Naming Conventions* — permit snake case for
value names, make the acronym rule context-free by keeping acronyms upper throughout, and call
the entity-type convention by the name of the convention the section actually describes.
**Normative impact:** None. §1.2.2 already states that parsers should not enforce these
conventions and that authors are free to differ.

**Related documents:** [modeling-methodology](modeling-methodology.md) · [profile-organization](profile-organization.md) ·
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
3. **Name the entity-type convention Pascal case**, which is what the section describes and
   every one of its examples uses.

No change is proposed to the entity-type rule itself. It draws the one distinction a reader
cannot recover from position, and it should stay exactly as it is; only what it is called
changes.

## What the specification says today

§1.2.2 sets out five conventions: snake case for keynames, dash case for value names, camel case
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

### The cost is paid where a name crosses into code

The purpose of the language is that modelled values reach implementations, and at that boundary a
value name becomes an identifier. A property named `mgmt-address` is not a legal shell variable,
not a Python identifier, and not a Go struct field. Wherever it is bound to one it must be
transliterated, and transliteration is ambiguous in both directions: `mgmt_address` could have
come from either spelling. Snake case is a legal identifier in very nearly every host language,
which is why authors reach for it precisely where a name has to cross into code.

How much this costs depends on how an orchestrator passes values to an artifact, which the
specification leaves open:

- **One environment variable per input**, the convention the community profiles document today:
  a dash-case name cannot be passed at all. It is not awkward but unusable, and a shell's
  identifier rules end up setting a naming rule for the language.
- **One structured document**, as
  [artifact-calling-convention-proposal.md](artifact-calling-convention-proposal.md) proposes for
  the community artifact types: a dash-case name is an ordinary key, and Bash and Python read it
  directly. What remains is every binding that turns a key into an identifier — a Go struct field
  needing a tag, a generated class needing an alias, an SDK mapping TOSCA types onto native ones.

So the sharpest form of this cost is a property of the transport, and a profile convention can
remove it; that convention is a proposal rather than settled practice, and an orchestrator is
free never to adopt it. The rest of the cost belongs to the language: a preferred spelling that
most host languages cannot use as an identifier puts a conversion in front of every consumer that
generates code from a profile. Permitting the spelling those consumers already write removes it,
and costs a reader nothing.

### The specification already prefers snake case where a name must be an identifier

The same section that prefers dash case for value names prescribes snake case for function
names, *"the built-in functions as well as custom functions"*. A custom function name is
authored content, exactly as a property name is, and it is written in value position. What
separates it from a keyname is the `$` sigil, not its spelling, so the differentiation rationale
does not reach it either.

What does separate it is that a function name has to be an identifier. A profile binds each
custom function to an implementation, and `community.tosca.core` names the entry point in each
Python file after the TOSCA function it implements. `$decode_yaml` could not be spelled
`$decode-yaml` and keep that correspondence.

So §1.2.2 already draws the line this amendment asks for, one class of names earlier: where an
authored name crosses into code, it prefers the spelling code can use. Property, attribute and
input names cross the same boundary, for the same reason, and are asked to use the spelling that
cannot.

### The convention is not being followed

Property and attribute names counted across three independently authored profile families — the
TOSCA community profiles, the Ubicity profiles, and the O-PAS Part 9 profiles:

| Profile family | dash | snake | Pascal | one word | total |
|---|---:|---:|---:|---:|---:|
| TOSCA community | 9 | 20 | 0 | 31 | 60 |
| Ubicity | 2 | 101 | 0 | 101 | 204 |
| O-PAS Part 9 | 0 | 54 | 85 | 40 | 179 |
| **All three** | **11** | **175** | **85** | **172** | **443** |

The 85 Pascal case names are O-PAS profiles mirroring the Pascal case of the O-PAS Part 9 schema,
so they are not free choices. Excluding them leaves 358 names chosen by an author, of which 11
use the preferred convention.

Four distinct dash-case names exist across all three families — `implementation-details`,
`ip-address`, `target-port`, `transport-port` — and a fifth, `mgmt-address`, in the Ubicity
profiles alone.

The sharpest measure is operation inputs, where a name must become a variable inside a script
under today's convention. Across the same profiles there are **143 declared operation inputs and
not one uses dash case**: 80 snake case, 63 single words. Authors are not rejecting the
convention on taste; they abandon it at exactly the boundary where it stops working. The measure
is of the convention in force when those profiles were written: pass values as one document and
the boundary moves, but the names already chosen are what authors reach for when a name has to
become an identifier.

### Where dash case is the norm, and where it is not

Dash case is not an odd choice, and the amendment does not claim it is. It is the norm wherever
a name stays text: CSS properties (`background-color`), HTML attributes (`aria-label`) and
custom element names, which the HTML specification requires to contain a hyphen; HTTP header
fields (`Content-Type`); DNS labels and URL slugs, where an underscore is not permitted at all;
command-line options (`--dry-run`); package names on npm and Debian; Kubernetes object names,
which are RFC 1123 labels. In none of these does the name become a variable in a program.

The case that deserves a direct answer is **YANG** (RFC 7950), and the models built on it. YANG
is a modelling language for systems, the closest analogue TOSCA has, and its identifiers are
dash case: `oper-status`, `router-id`, `admin-state`. Anyone arguing against this amendment
should raise it, and it is visible in TOSCA profiles already: the `net.openconfig` profile in
the Ubicity set, generated from OpenConfig models, carries `router-id`, `next-hop`,
`route-distinguisher` and `interface-ref` straight from the YANG. Generated profiles are
excluded from the counts above, for the reason the method gives, and cited here as prior art
rather than as an author's choice.

What YANG shows, though, is what happens next. A YANG name is not usable as an identifier in the
languages that consume the model, so every binding converts it: `pyangbind` turns `oper-status`
into `oper_status` to make it a Python attribute, and the same conversion appears in Java, Go and
C bindings. The dash survives in the model and is transliterated at every code boundary. That is
precisely the cost described above, paid by an ecosystem large enough to have automated it.

TOSCA's position differs in one way that matters. A YANG model is consumed through generated
bindings, where a naming rule is applied once by a generator. A TOSCA property reaches an
implementation through an artifact a human wrote, in a language of that author's choosing, with
no generator in between. Where there is no binding layer to absorb the conversion, the author
absorbs it.

### What this proposes

Permit either separator for value names, consistent within a profile, and remove the
differentiation rationale. The remaining conventions then collapse into two a reader can hold:
**Pascal case for entity types, lower case with a separator for everything else.** It also brings
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

## 3. The entity-type rule is called camel case and describes Pascal case

> *TOSCA entity type names*: camel case. This includes all TOSCA entity types: nodes,
> relationships, capabilities, artifacts, data, etc. Examples: "Server", "BlockStorage",
> "OperatingSystem", "VirtualLink". *All* words in the name should be capitalized, *including
> prepositions*.

Camel case and Pascal case differ in one letter: the first. `blockStorage` is camel case,
`BlockStorage` is Pascal case. The rule's own text asks for *all* words to be capitalized, and
each of its examples begins with a capital, so what it describes is Pascal case throughout.
Nothing in the specification uses lower camel case for anything.

The section says "camel case" a second time, about the types that replace the `scalar-unit.`
prefix, and the specification's own replacements are `Bitrate`, `Frequency`, `Size` and `Time`:
Pascal case again. "Pascal case" appears nowhere in the document. So the term is used twice and
contradicted by every example under it.

The cost is a reader who follows the words rather than the examples. In Java and JavaScript,
where both conventions are in daily use, "camel case" unqualified means the lower form, so a
newcomer reads the rule as asking for `blockStorage`. No profile writes that and no example
shows it, which makes this the one convention in §1.2.2 that a careful reader can follow and
still get wrong.

### What this proposes

Say **Pascal case** where the section means Pascal case, keeping the examples as they are. If
the TC prefers to keep the term "camel case", the sentence should say "camel case with the first
word capitalized (also called Pascal case)", so the text and the examples agree.

## 4. What is not proposed

**The entity-type rule stays.** Whether a name denotes a type or an instance is the one
distinction a reader cannot recover from position, and a visual cue earns its cost there. Nearly
every language draws it the same way, and the rule is followed in practice. Amendment 3 changes
only what the convention is called.

**Snake case for keynames and functions stays**, and so do lower-case whole words for primitive
types. The function rule is cited above as the precedent for this amendment, not as something to
change.

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
