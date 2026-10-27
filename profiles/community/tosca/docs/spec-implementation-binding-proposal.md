# Attaching Implementations to Imported Definitions

*Drafted with an AI assistant (Claude); reviewed and submitted by Chris Lauwers.*

**Status:** Proposal — for discussion. Tracked as I9, I43 and I55.
**Audience:** TOSCA Community, and the OASIS TOSCA Technical Committee for the grammar in
Sections 1 to 5.
**Purpose:** Let a technology-independent profile declare functions and operations with no
implementations, and let each orchestrator supply its own, without deriving new types, without
the service template author expressing anything, and without any orchestrator being expected to
support an execution environment it does not have.
**Normative impact:** New grammar. Every document valid today stays valid: the constructs are
optional, and nothing about existing implementation definitions changes.

**Related documents:** [artifact-conventions](artifact-conventions.md) ·
[modeling-methodology](modeling-methodology.md) · discussions
[#365](https://github.com/oasis-open/tosca-community-contributions/discussions/365) and
[#384](https://github.com/oasis-open/tosca-community-contributions/discussions/384)

---

A profile that declares a function or an operation can offer an implementation for one processor
only. A second processor cannot supply its own without owning the declaration, so a profile meant
to be shared is usable as published by the processors whose artifacts it happens to name, and must
be edited by the rest. Editing a published profile is a fork, and a fork of a standard library is
the thing a standard library exists to prevent.

## What is being asked

Of the TC:

1. **Give a function signature a name**, so that something other than its position in a list can
   address it.
2. **Add an `implementations` section**: a top-level keyname that lets any TOSCA file supply
   implementations for functions and operations declared in a profile it imports, naming each
   target as the file's namespaces resolve it.
3. **Let a processor be configured with companion profiles**, profiles whose only content is an
   `implementations` section, that apply wherever their target profile is imported, so that a
   service template imports the technology-independent profile and nothing else.

Of the community:

4. **`core` ships signatures only**, as D16 decided for the `0.2`, and each orchestrator supplies
   its implementations for the execution environment it already runs, in a profile of its own
   that imports `core` or in a companion profile.

## What the specification says today

**An operation is declared without an implementation, and receives one by refinement.**
`TOSCA-v2.0-os.md` §11.4 *Operation Definition*, in the keyname table:

> May not be used in an interface type definition (i.e. where an operation is initially
> defined), but only during refinements.

and in the prose above it:

> An operation definition or refinement inside an interface type definition may not contain an
> operation implementation definition [...]

The refinement sites it offers are a node or relationship type refining an interface it
inherits, and a template assigning an implementation, which §11.5 *Operation Assignment* makes
the strongest: *"The behavior for implementation of operations SHALL be overwrite."* One creates
types; the other puts the choice of implementation into the model.

**A function may carry an implementation where it is declared, or none.** `TOSCA-v2.0-os.md`
§10.4 *Function Definitions*: *"None of the keynames in the signature definition are
mandatory"*, and where no implementation is specified, *"it's assumed that the TOSCA processor is
preconfigured to handle the function call."*

**A function is refined only inside a service template.** §10.4: *"Function definitions inside a
service_template that have the same `<function_name>` are considered a refinement of the
homonymous definition outside the service_template"*, and *"for an already defined signature only
the implementation may be changed."* A signature is addressed by position: *"If an existing
signature is not refined, an empty element must be used at the relevant location in the list."*

**A function name is defined once.** §10.4: *"Overlapping definitions under the same
`<function_name>` are not allowed."* Importing under a namespace avoids the collision by changing
every call to `$namespace:function_name`.

Who may therefore supply an implementation:

| supplied by | function | operation |
|---|---|---|
| the file that declares it | yes | no, for an interface type |
| a type derived from the declaring type | not applicable | yes, by refinement |
| a service template that uses it | yes, by refinement | yes, by assignment |
| a profile that declares neither | **no** | **no** |

**The gap is the last row: a refinement site that is neither a derived type nor a service
template.** §10.4 already defines the restriction such a site needs, implementation only, and
scopes it to the service template.

## 1. A signature needs a name

A function holds an ordered list of signatures, and nothing names one. Positional addressing
cannot carry a refinement written in another document: a signature inserted into the declaration
silently rebinds every refinement after it, and an empty element is indistinguishable from a
signature that legitimately takes no arguments. The defects are filed as
[oasis-tcs/tosca-specs#376](https://github.com/oasis-tcs/tosca-specs/issues/376), which is a
prerequisite for this proposal.

**Proposed:** an optional `name` keyname on a signature definition, unique within the function.

```yaml
functions:
  to_string:
    signatures:
      - name: integer
        arguments:
          - type: integer
        result:
          type: string
      - name: float
        arguments:
          - type: float
        result:
          type: string
```

## 2. The `implementations` section

**`implementations`** binds implementations to definitions contributed by an imported profile.
Its contents mirror the grammar of the entity being refined, and `implementation` is the only
keyname permitted inside, holding an implementation definition in the grammar functions and
operations already use.

**A target is named as any reference in the file is named.** A function or type imported into
the default namespace is named as declared, `to_string`; one imported under a namespace takes its
prefix, `cc:to_string` or `k8s:Kubernetes`. The namespace rules already make every such name
resolve to exactly one definition in the file that writes it, so a refinement never has to guess
which of several homonymous definitions it means, and two imports under different namespaces may
each contribute a function of the same name and be refined separately.

Where one artifact implements many definitions, as a single plugin may implement every function
of a profile, the definition is written once and repeated with a YAML anchor and aliases, as in
the examples below. The binding and the implementation always sit in the same file, so a name
that connects them would add a lookup and nothing else.

Refinements sit in a section of their own rather than in `functions` or `node_types`. A
homonymous entry under `functions` reads as a declaration, and under nominal typing an entry in
`node_types` naming an imported type is an error today, so reusing either would need a marker
anyway. A separate section makes the refinement explicit and the implementation-only restriction
checkable by position rather than by rule. It is also why one function name never gains two
definitions, which is what §10.4's rule against overlapping definitions prevents: the declaration
stays the only definition, and the refinement can change nothing but the implementation.

**Any profile may carry the section**, and two forms follow from where it sits:

- **In a profile that also declares definitions of its own.** An orchestrator's own profile that
  already imports the target, and that templates written for the orchestrator already import,
  supplies the target's implementations beside its own types and functions. Templates receive
  them through the imports they already have.
- **In a companion profile**, whose only content is the section and the imports it needs. A
  template may import a companion profile, and a processor may be configured with one so that a
  template importing only the target receives its implementations (Section 5).

## 3. Functions

The target profile, shipping no implementation:

```yaml
tosca_definitions_version: tosca_2_0
profile: community.tosca.core:0.2

functions:
  to_uppercase:
    signatures:
      - name: string
        arguments:
          - type: string
        result:
          type: string
```

A companion profile for an orchestrator that runs WebAssembly plugins, naming its own artifact
type and its own file, and attaching one implementation to several functions:

```yaml
tosca_definitions_version: tosca_2_0
profile: community.tosca.core.wasm:0.2

imports:
  - profile: community.tosca.core:0.2
  - profile: com.example.wasm:1.0
    namespace: wasm

implementations:
  functions:
    to_uppercase:
      implementation: &core
        primary:
          type: wasm:WasmPlugin
          file: artifacts/core-0.2.wasm
    now:
      implementation: *core
```

An `implementation` directly under a function applies to every signature. A companion profile
for an orchestrator that runs Python, with one file per signature, addresses each by name:

```yaml
tosca_definitions_version: tosca_2_0
profile: community.tosca.core.python:0.2

imports:
  - profile: community.tosca.core:0.2

implementations:
  functions:
    to_string:
      signatures:
        integer:
          implementation:
            primary:
              type: Python
              file: functions/to_string_integer.py
        float:
          implementation:
            primary:
              type: Python
              file: functions/to_string_float.py
```

An orchestrator's own profile that imports `core` into its default namespace and declares
functions of its own, refining `core`'s beside them:

```yaml
tosca_definitions_version: tosca_2_0
profile: com.example.core:1.0

imports:
  - profile: community.tosca.core:0.2

functions:
  unique_name:
    signatures:
      - arguments:
          - type: string
        result:
          type: string
        implementation:
          primary:
            type: Python
            file: functions/unique_name.py

implementations:
  functions:
    to_uppercase:
      implementation:
        primary:
          type: Python
          file: functions/to_uppercase.py
```

The same profile importing `core` under a namespace names the target with its prefix, and a
template then calls it as `$cc:to_uppercase`:

```yaml
imports:
  - profile: community.tosca.core:0.2
    namespace: cc

implementations:
  functions:
    cc:to_uppercase:
      implementation:
        primary:
          type: Python
          file: functions/to_uppercase.py
```

## 4. Operations

The same section carries the entity kinds that may declare an interface: `interface_types`,
`node_types`, `relationship_types`, `group_types` and `policy_types`.

```yaml
tosca_definitions_version: tosca_2_0
profile: io.kubernetes.wasm:1.36

imports:
  - profile: io.kubernetes:1.36
    namespace: k8s
  - profile: com.example.wasm:1.0
    namespace: wasm

implementations:
  interface_types:
    k8s:Kubernetes:
      operations:
        create:
          implementation: &kubernetes
            primary:
              type: wasm:WasmPlugin
              file: artifacts/kubernetes-1.36.wasm
        delete:
          implementation: *kubernetes

  node_types:
    k8s:Deployment:
      interfaces:
        Kubernetes:
          operations:
            apply:
              implementation: *kubernetes
```

Refining an interface type's operation is the case §11.4 has no site for today: it permits an
implementation only during refinement, and every refinement site available derives a type or sits
in a service template.

## 5. How a template gets the implementations

**By import.** A service template, or a profile, that imports a file carrying an
`implementations` section gets its implementations under the ordinary rules for imports, whether
that file is an orchestrator's own profile or a companion profile. This needs nothing of a
processor beyond the grammar in Sections 1 and 2.

**By configuration.** A processor may be configured with companion profiles, each applying
wherever its target profile is imported. A service template then imports the target profile and
nothing else: it never names a companion profile, because which implementation runs is not a
modelling question. This is §10.4's *"preconfigured to handle the function call"* given a form
that can be inspected, and extended to operations.

**Configuring a profile is what makes it a companion.** The file carries no marker: any profile
with an `implementations` section may be imported, and the same file may be imported by one
template and configured into a processor. What distinguishes a companion is the operator's act of
configuring it, so a processor always knows which of its profiles are companions. At that act it
checks that the file qualifies, containing nothing but an `implementations` section and the
imports it needs, and refuses it otherwise: a profile applied without being imported must not
bring types or functions into a template that never asked for them.

**A companion's targets are the profiles whose definitions it refines**, not every profile it
imports. A companion may import a profile only for the artifact types its implementations name,
as the WebAssembly example imports `com.example.wasm`; that import makes it no target. A
companion refining definitions from two profiles applies wherever either is imported.

**A configured companion that a template also imports is one source.** Its refinements arrive
once, and do not conflict with themselves under the rule in Section 7 against two files refining
the same definition.

Configuration happens in two steps. **Onboarding installs the binding.** The companion profile
enters the processor's catalog beside the profile it refines, and is checked there against that
profile's definitions and against any other profile refining them, so a refinement that cannot apply
is refused before any service template exists. **An import puts it into effect.** When a template
imports the target profile, the processor resolves the target's definitions together with the
implementations it holds for them. The target profile is never modified: it stays as published,
and the binding lives beside it.

A processor with no implementations for a target can still parse, validate and reason about
every template that imports it, and fails only if asked to execute an operation or evaluate a
function for which it has no implementation. That is the §18.3 processor and §18.4 orchestrator
split, unchanged. The target profile is also self-contained: it names no implementation it
cannot resolve and imports nothing that exists only per orchestrator, so a processor with no
orchestration capability reads it as published.

## 6. The community profiles

`core` declares its functions' signatures and ships no implementations (D16). Each orchestrator
supplies its own for the execution environment it already runs, in a profile of its own that
templates written for it already import, or in a companion profile, so declaring `core` creates
no expectation that any orchestrator support Bash, Python or WebAssembly, and no user installs an
interpreter their orchestrator does not use.

Two consequences follow for `core`:

- **Data types that validate through a function** depend on an implementation like any call.
  `JSON` and `YAML` validate through `$validate_json` and `$validate_yaml`, so a processor with
  no implementation of them can parse a value of either type and cannot check it.
- **Where companion profiles are published** is open. They belong with whoever ships the
  execution environment, which argues against the community repository hosting them; a
  companion for one orchestrator is still a useful example of the convention (I9).

## 7. Rules that need to be decided

- **A function implementation at its declaration.** Operations may not carry one where they are
  declared (§11.4). Aligning functions with them would make an implementation reach a function
  only by refinement, and would break any profile that ships function implementations today.
- **Conflicts.** Two files refining the same definition for one template are an error, whether
  imported or configured, rather than resolved by a precedence rule. A precedence rule would make
  the effective implementation depend on import order or on what happens to be installed, where
  the point of the design is that a model means one thing.
- **Templates.** Whether a template may still override an implementation an `implementations`
  section supplies. Allowing it keeps §11.5's behavior; forbidding it keeps the choice out of the model
  entirely.
- **Permitted keynames.** `implementation` only, including an artifact's own `properties`.
  Arguments, results, inputs and outputs, descriptions and metadata belong to the target and are
  matched rather than redefined.
- **Artifact paths.** `file` is relative to the archive root of the profile carrying the
  section, not the target's.
- **Validation.** A refinement naming an entity, interface, operation, function or signature that
  does not resolve in its file is an error, detectable when the profile is onboarded, without a
  service template.
- **Refinement and derivation.** What a type derived from a refined type inherits, and whether a
  profile may refine a type that another profile derived.
- **Substitution.** Whether a substituting template's own imports may bring implementations, and
  if so whose refinements apply inside the substituted service.
- **Onboarding order and versions.** A companion profile imports its target, so the target is
  onboarded first, and a companion refines one version of it: onboarding a new version of the
  target needs a companion for that version, and a template importing a version with no companion
  is in the position of a processor with none.
- **Scope of a configured binding.** A binding is global to the processor: every template
  importing the target gets the same implementations. That is the purpose, but it leaves no way
  for two tenants of one orchestrator to choose differently, and whether one should is a question
  for the operator rather than the model.
- **Change over time.** If a configured companion profile is replaced, a service deployed under
  the old one runs the new implementations at its next operation, unless the orchestrator records
  which companion was in effect when the service was deployed and keeps applying it. That is
  closer to an operational rule than a grammar rule, but the claim that a model means one thing
  depends on it.

## 8. What is not proposed

- **No change to how an implementation is described.** The implementation definition grammar is
  reused as it stands.
- **No obligation on a processor** to support any particular artifact type, or to accept
  configured companion profiles. A processor executes what it executes.
- **No change to the contract.** An `implementations` section cannot alter a signature, an operation's
  parameters, or anything else a consumer depends on.
- **No preprocessing.** Selecting an implementation is a processor decision at parse or run time,
  not a textual variant of the file.

## 9. Alternatives

**Extend §10.4's refinement scope** from the service template to any profile that imports the
definition, so that a homonymous entry under `functions` refines it. It needs little new
grammar, but a homonymous entry cannot say which function it refines. It reads as a declaration,
it has to be exempted from the rule against overlapping definitions, and it cannot reach a
function imported under a namespace at all, since a key under `functions` declares and never
takes a prefix. It also covers functions only, and §10.4's refinement may add signatures and
overwrite descriptions, which in a profile would change a function's contract for everything that
imports it. The `implementations` section gives the same profile-level refinement explicitly,
namespaced and implementation-only, for operations as well.

**Named implementations.** Tal Liron proposed in #384 a top-level `implementations` keyname with
a different meaning from the one proposed here: it maps a symbolic name to an implementation
definition, with `implementation` accepting the name wherever a definition is allowed. In his
form the name is what connects two files: the profile that declares a function holds the name,
and imports an `implementations:0.1` profile whose content each orchestrator maps to its own
file. Here the binding and the implementation are always in the same file, so the name
connects nothing that is not already together, and the reuse it offers within a file is what
YAML anchors already give. The remapping itself is declined for two reasons. The declaring
profile stops being self-contained, since it holds a name it cannot resolve and imports a
profile that exists only per orchestrator. And one profile name then denotes different content
on different engines, where §6.7.3 asks designers to *"use the proper string name to make sure
they import the desired versions of these profiles"*.

**Several implementations in one published set, the processor choosing the first it can
execute.** One set of artifacts would then serve several processors, but the declaring profile or
a shared binding file must name every artifact type in advance, and what runs depends on what a
processor can execute rather than on what was configured.

**Import under a namespace and declare a second function.** Legal today, and it changes every
call site, so a template becomes specific to one processor.

**Conditional variability.** Variability4TOSCA and OpenTOSCA Vintner put conditions on templates,
properties and deployment artifacts, and a preprocessor resolves them against inputs the modeller
supplies. That answers which product variant is wanted, selects in a tool outside the
orchestrator, and emits generated types. This answers which engine is running, selects in the
orchestrator that owns the execution environment, and emits nothing.

**Derivation.** A type per implementation technology changes the type name every template
mentions, and produces the profile proliferation the community modelling methodology rejects.

## 10. Adjacent: implementation types

Tal Liron has proposed that implementations have their own type system rather than reusing
artifact types. A file is not a universal way to name an implementation: a library or namespace
reference, or a call to an execution service, are reasonable too, and an artifact type conflates
the artifact with how it is invoked. Implementation types would make the contract at the boundary
between processor and implementation a typed, first-class thing.

It is a larger change than attachment and separable from it. Attachment works with artifact types
today and would work with implementation types unchanged, since both appear only inside
`implementation`.
