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
2. **Add an `implements` keyname**: a TOSCA file that names a profile it implements may only add
   implementations to that profile's definitions, written in the grammar that declared them.
3. **Let a processor be configured with implementing files** that apply wherever the profile they
   implement is imported, so that a service template imports the technology-independent profile
   and nothing else.

Of the community:

4. **`core` ships signatures only**, as D16 decided for the `0.2`, and each orchestrator supplies
   its implementations for the execution environment it already runs, in a file that implements
   `core`.

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

## 2. The `implements` keyname

**`implements`** names a profile, by the same name and version an import of it would use. A
TOSCA file that carries it is an *implementing file*, and everything it defines adds
implementations to the definitions of the profile it implements:

- **The implemented profile's definitions are in scope by their declared names**, as if the
  profile were imported into the file's default namespace, so a refinement never takes a prefix
  and never has to resolve which of several homonymous definitions it means: there is one
  implemented profile, and its names are unique within it.
- **Every entry is a refinement.** An entry under `functions`, `interface_types`, `node_types`,
  `relationship_types`, `group_types` or `policy_types` must name a definition of the implemented
  profile, and may contain only `implementation`, with the keynames that lead to it: `signatures`
  and a signature's `name` for a function, `interfaces` and `operations` for an operation.
- **The file declares nothing of its own**: no types, no functions, no service template.
- **Other imports are ordinary.** A file may import the profile that declares the artifact types
  its implementations name, under a namespace or not, and nothing it contributes can be refined.

The keyname switches what the file's sections mean: under `implements`, `node_types: Deployment:`
refines the implemented `Deployment` where an ordinary file would declare one. `profile` already
changes what a file is in the same way. The switch is also what lets the file use the grammar
that declared the definitions, rather than a parallel grammar for refinements. And since the file
declares nothing, a refinement is never a second definition of the same name, which is what
§10.4's rule against overlapping definitions prevents.

An implementing file follows the ordinary rule for `profile`: the keyname is optional, and the
file needs a name of its own only to be imported by profile name, as an orchestrator's own
profile imports one in Section 3. A processor configured with the file finds it by its
`implements` value rather than its name. A name with its own version is still the natural way to
release a corrected implementation of an unchanged profile, and to identify which file was in
effect for a service. Where one artifact implements many definitions, as a single plugin may
implement every function of a profile, the definition is written once and repeated with a YAML
anchor and aliases.

## 3. Functions

The implemented profile, shipping no implementation:

```yaml
tosca_definitions_version: tosca_2_0
profile: community.tosca.core:0.2

functions:
  to_uppercase:
    signatures:
      - arguments:
          - type: string
        result:
          type: string
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

An implementing file for an orchestrator that runs WebAssembly plugins, naming its own artifact
type and its own file, and attaching one implementation to several functions. A signature entry
without a `name` refines a function's only signature:

```yaml
tosca_definitions_version: tosca_2_0
profile: community.tosca.core.wasm:0.2
implements: community.tosca.core:0.2

imports:
  - profile: com.example.wasm:1.0
    namespace: wasm

functions:
  to_uppercase:
    signatures:
      - implementation: &core
          primary:
            type: wasm:WasmPlugin
            file: artifacts/core-0.2.wasm
  to_string:
    signatures:
      - name: integer
        implementation: *core
      - name: float
        implementation: *core
```

An implementing file for an orchestrator that runs Python, with one file per signature:

```yaml
tosca_definitions_version: tosca_2_0
profile: community.tosca.core.python:0.2
implements: community.tosca.core:0.2

functions:
  to_string:
    signatures:
      - name: integer
        implementation:
          primary:
            type: Python
            file: functions/to_string_integer.py
      - name: float
        implementation:
          primary:
            type: Python
            file: functions/to_string_float.py
```

An orchestrator's own profile, which templates written for that orchestrator already import,
declares its own functions and imports the implementing file, so those templates receive
`core`'s implementations through the imports they already have. How the profile imports `core`,
into its default namespace or under one, makes no difference to the implementing file:

```yaml
tosca_definitions_version: tosca_2_0
profile: com.example.core:1.0

imports:
  - profile: community.tosca.core:0.2
    namespace: cc
  - profile: community.tosca.core.python:0.2

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
```

## 4. Operations

```yaml
tosca_definitions_version: tosca_2_0
profile: io.kubernetes.wasm:1.36
implements: io.kubernetes:1.36

imports:
  - profile: com.example.wasm:1.0
    namespace: wasm

interface_types:
  Kubernetes:
    operations:
      create:
        implementation: &kubernetes
          primary:
            type: wasm:WasmPlugin
            file: artifacts/kubernetes-1.36.wasm
      delete:
        implementation: *kubernetes

node_types:
  Deployment:
    interfaces:
      Kubernetes:
        operations:
          apply:
            implementation: *kubernetes
```

Refining an interface type's operation is the case §11.4 has no site for today: it permits an
implementation only during refinement, and every refinement site available derives a type or sits
in a service template. In an implementing file the refinement creates no type: `Deployment` is
still the implemented profile's `Deployment`, so a template that names it, and a substitution that
matches it, are unchanged.

## 5. How a template gets the implementations

**By import.** A service template, or a profile, that imports an implementing file gets its
implementations under the ordinary rules for imports. An orchestrator's own profile can import
one, as in Section 3, and pass it on to every template that imports that profile. This needs
nothing of a processor beyond the grammar in Sections 1 and 2.

**By configuration.** A processor may be configured with implementing files, each applying
wherever the profile it implements is imported. A service template then imports the implemented
profile and nothing else: it never names an implementing file, because which implementation runs
is not a modelling question. This is §10.4's *"preconfigured to handle the function call"* given
a form that can be inspected, and extended to operations. `implements` is both what makes a file
eligible, since a file that declares nothing cannot bring types or functions into a template
that never asked for them, and the key the processor looks it up by when a template imports the
implemented profile.

Configuration happens in two steps. **Onboarding installs the binding.** The implementing file
enters the processor's catalog beside the profile it implements, and is checked there against
that profile's definitions and against any other file implementing them, so a refinement that
cannot apply is refused before any service template exists. **An import puts it into effect.**
When a template imports the implemented profile, the processor resolves its definitions together
with the implementations it holds for them. The implemented profile is never modified: it stays
as published, and the binding lives beside it.

**A configured implementing file that a template also imports is one source.** Its refinements
arrive once, and do not conflict with themselves under the rule in Section 7.

A processor with no implementations for a profile can still parse, validate and reason about
every template that imports it, and fails only if asked to execute an operation or evaluate a
function for which it has no implementation. That is the §18.3 processor and §18.4 orchestrator
split, unchanged. The implemented profile is also self-contained: it names no implementation it
cannot resolve and imports nothing that exists only per orchestrator, so a processor with no
orchestration capability reads it as published.

## 6. The community profiles

`core` declares its functions' signatures and ships no implementations (D16). Each orchestrator
supplies its own for the execution environment it already runs, in a file that implements
`core`, configured into the orchestrator or imported by the orchestrator's own profiles. Declaring
`core` then creates no expectation that any orchestrator support Bash, Python or WebAssembly, and
no user installs an interpreter their orchestrator does not use.

Two consequences follow for `core`:

- **Data types that validate through a function** depend on an implementation like any call.
  `JSON` and `YAML` validate through `$validate_json` and `$validate_yaml`, so a processor with
  no implementation of them can parse a value of either type and cannot check it.
- **Where implementing files are published** is open. They belong with whoever ships the
  execution environment, which argues against the community repository hosting them; one for a
  single orchestrator is still a useful example of the convention (I9).

## 7. Rules that need to be decided

- **A function implementation at its declaration.** Operations may not carry one where they are
  declared (§11.4). Aligning functions with them would make an implementation reach a function
  only by refinement, and would break any profile that ships function implementations today.
- **Conflicts.** Two implementing files refining the same definition for one template are an
  error, whether imported or configured, rather than resolved by a precedence rule. A precedence
  rule would make the effective implementation depend on import order or on what happens to be
  installed, where the point of the design is that a model means one thing. Files refining
  disjoint parts of one profile do not conflict.
- **Templates.** Whether a template may still override an implementation an implementing file
  supplies. Allowing it keeps §11.5's behavior; forbidding it keeps the choice out of the model
  entirely.
- **Permitted keynames.** `implementation` only, including an artifact's own `properties`, with
  the keynames that lead to it. Arguments, results, inputs and outputs, descriptions and metadata
  belong to the implemented profile and are matched rather than redefined.
- **Artifact types.** Whether an implementing file may declare the artifact types its
  implementations name, or must import them as Section 2 has it.
- **Artifact paths.** `file` is relative to the implementing file's own archive root, not the
  implemented profile's.
- **Validation.** An entry naming an entity, interface, operation, function or signature the
  implemented profile does not define is an error, detectable when the file is onboarded, without
  a service template.
- **Refinement and derivation.** Whether a type that another profile derives from a refined type
  inherits the implementation, and whether an implementing file may refine a type that the
  implemented profile itself imports from elsewhere.
- **Substitution.** Whether a substituting template's own imports may bring implementations, and
  if so whose refinements apply inside the substituted service.
- **Versions.** `implements` names one version of a profile, so a new version needs its own
  implementing file, and a template importing a version with none is in the position of a
  processor with none.
- **Scope of a configured binding.** A binding is global to the processor: every template
  importing the implemented profile gets the same implementations. That is the purpose, but it
  leaves no way for two tenants of one orchestrator to choose differently, and whether one should
  is a question for the operator rather than the model.
- **Change over time.** If a configured implementing file is replaced, a service deployed under
  the old one runs the new implementations at its next operation, unless the orchestrator records
  which file was in effect when the service was deployed and keeps applying it. That is closer to
  an operational rule than a grammar rule, but the claim that a model means one thing depends
  on it.

## 8. What is not proposed

- **No change to how an implementation is described.** The implementation definition grammar is
  reused as it stands.
- **No obligation on a processor** to support any particular artifact type, or to accept
  configured implementing files. A processor executes what it executes.
- **No change to the contract.** An implementing file cannot alter a signature, an operation's
  parameters, or anything else a consumer depends on.
- **No preprocessing.** Selecting an implementation is a processor decision at parse or run time,
  not a textual variant of the file.

## 9. Alternatives

**An `implementations` section in any profile.** A top-level section mirroring the grammar of the
definitions it refines, allowed in any profile beside its own definitions, with targets named
through the file's namespaces (`cc:to_uppercase`, `k8s:Kubernetes`). It lets one file both
declare and implement, but it needs a parallel grammar for refinements, infers a file's targets
from what it refines rather than stating them, and leaves a processor to inspect a file's
content to decide whether it may be configured. `implements` states the target once and makes
eligibility a property of the file.

**Extend §10.4's refinement scope** from the service template to any profile that imports the
definition, so that a homonymous entry under `functions` refines it. It needs little new
grammar, but in an ordinary file a homonymous entry cannot say which function it refines. It
reads as a declaration, it has to be exempted from the rule against overlapping definitions, and
it cannot reach a function imported under a namespace at all, since a key under `functions`
declares and never takes a prefix. It also covers functions only, and §10.4's refinement may add
signatures and overwrite descriptions, which in a profile would change a function's contract for
everything that imports it. `implements` keeps the homonymous form and removes each of these
problems by declaring the file's purpose.

**Named implementations.** Tal Liron proposed in #384 a top-level `implementations` keyname that
maps a symbolic name to an implementation definition, with `implementation` accepting the name
wherever a definition is allowed. In his form the name is what connects two files: the profile
that declares a function holds the name, and imports an `implementations:0.1` profile whose
content each orchestrator maps to its own file. `implements` reverses the direction of the
reference: the implementing file names the profile it implements, and the implemented profile
names nothing. The remapping is declined for two reasons. The declaring profile stops being
self-contained, since it holds a name it cannot resolve and imports a profile that exists only
per orchestrator. And one profile name then denotes different content on different engines,
where §6.7.3 asks designers to *"use the proper string name to make sure they import the desired
versions of these profiles"*. Within one implementing file, the reuse a symbolic name offers is
what YAML anchors already give.

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
