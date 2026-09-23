# Binding Implementations to Functions and Operations

**Status:** Draft — not submitted.
**Audience:** OASIS TOSCA Technical Committee. This document addresses the specification rather
than the community profiles.
**Purpose:** Propose a construct that lets a TOSCA file supply an implementation for a function or
an operation declared elsewhere, and lets a processor choose among several.
**Normative impact:** New grammar. Every document valid today stays valid: the construct is
optional, and nothing about existing implementation definitions changes.

**Related documents:** [modeling-methodology](modeling-methodology.md) ·
[artifact-calling-convention-proposal](artifact-calling-convention-proposal.md)

---

A profile that declares a function or an operation can offer an implementation for one processor
only. A second processor cannot supply its own without owning the declaration, so a profile meant
to be shared is usable as published by the processors whose artifacts it happens to name, and must
be edited by the rest. Editing a published profile is a fork, and a fork of a standard library is
the thing a standard library exists to prevent.

## What is being asked

1. **Give a function signature an identity**, so that something other than its position in a list
   can address it.
2. **Add a binding construct** that supplies an implementation for a function or an operation
   declared elsewhere, without redeclaring it and without deriving a new type.
3. **State how a processor selects** among several bindings, and in what order bindings, type
   definitions and template assignments take precedence.

## What the specification says today

**A function implementation is optional, and its absence is meaningful.** `TOSCA-v2.0-os.md`
§10.4 *Function Definitions*:

> If no implementation is specified, then it's assumed that the TOSCA processor is preconfigured
> to handle the function call.

**A function name may be defined once.** `TOSCA-v2.0-os.md` §10.4:

> Namespacing works as for types. Overlapping definitions under the same `<function_name>` are not
> allowed.

An import under a namespace avoids the collision by changing the call to
`$namespace:function_name`, which changes every template that calls it.

**A function may be refined only inside a service template.** `TOSCA-v2.0-os.md` §10.4 describes
"two separated design moments", the profile and the service template, and gives refinement rules
for the second. There is no third.

**An operation implementation may be supplied after the fact, by a template.**
`TOSCA-v2.0-os.md` §11.5 *Operation Assignment*:

> An operation assignment may add or change the implementation and description definition of the
> operation.

> The behavior for implementation of operations SHALL be overwrite. That is, implementation
> definitions assigned in an operation assignment override any defined in the operation
> definition.

**Or by a derived type**, through operation refinement in a node or relationship type
(`TOSCA-v2.0-os.md` §11.4 *Operation Definition*).

## 1. The gap is who may supply an implementation, not whether one may be supplied late

Supplying an implementation late is already normal. What decides whether it is possible is
ownership of the declaration:

| supplied by | function | operation |
|---|---|---|
| the file that declares it | yes | yes |
| a type derived from the declaring type | not applicable | yes, by refinement |
| a service template that uses it | yes, by refinement | yes, by assignment |
| a profile that declares neither | **no** | **no** |

The last row is the one that matters for a shared profile. A technology profile that knows how an
operation is carried out on its target must derive a type to say so, which changes the type name
every template mentions and multiplies types for a reason that has nothing to do with modelling. A
profile that implements a community function cannot say so at all.

The consequence for functions is the sharper of the two, because a function has no type to derive
from. Either the declaring profile names an implementation, and every processor that cannot run it
must edit the profile, or it names none, and every processor must implement the function natively.

## 2. A signature needs an identity

A function definition holds an ordered list of signatures. Nothing names one, so a refinement
addresses a signature by its position and marks the untouched ones with "an empty element"
(`TOSCA-v2.0-os.md` §10.4). That mechanism cannot carry a binding written in another document: an
inserted signature silently rebinds every reference to the list, and an empty element is
indistinguishable from a signature that legitimately takes no arguments.

**Proposed:** an optional `name` keyname on a signature definition, unique within the function.

```yaml
functions:
  to_string:
    signatures:
      - name: from-integer
        arguments:
          - type: integer
        result:
          type: string
```

The defects in the existing positional rules are filed as
[oasis-tcs/tosca-specs#376](https://github.com/oasis-tcs/tosca-specs/issues/376) and are a
prerequisite for this proposal rather than part of it.

## 3. The binding construct

Two new keynames, usable in a TOSCA file outside `service_template`. Both reuse the implementation
definition grammar that operations and functions already use, so the new syntax is the envelope
and nothing else.

```yaml
function_implementations:
  - function: community.tosca.core:0.1:to_string    # the declaring profile and name
    signature: from-integer                         # optional; all signatures if omitted
    implementation:
      primary:
        type: Python
        file: functions/to_string.py

operation_implementations:
  - node_type: community.tosca.technology.base:0.1:Root
    interface: Standard
    operation: create
    implementation:
      primary:
        type: Ansible
        file: playbooks/create.yaml
```

A binding for a relationship type's operation names `relationship_type` in place of `node_type`.
A binding supplies an implementation; it may not restate arguments, results, inputs or outputs,
so the contract stays where it was declared.

## 4. Selection and precedence

- **Several bindings may target the same function or operation.** A processor uses the first whose
  artifact type it can execute. One set of published artifacts then serves processors that execute
  different kinds of implementation.
- **A binding whose artifact type the processor cannot execute is ignored**, not refused. Without
  this, importing a profile that binds an implementation for another processor would fail
  validation on every processor but one, which is the problem this proposal exists to remove.
- **Precedence, strongest first:** an operation assignment in a template; a binding in the
  importing file; a binding in an imported file; the implementation in the declaration itself.
- **Two executable bindings at the same level for the same target are an error**, rather than a
  silent choice between them.
- **A target with no binding and no implementation** keeps the meaning §10.4 gives it: the
  processor is preconfigured to handle the call.

## 5. What this makes possible

- **A shared library profile declares contracts and nothing else.** Consumers take it as
  published. A processor that implements the functions natively needs nothing more; one that runs
  them as artifacts imports the binding profile written for it.
- **A technology profile attaches implementations to types it does not own.** Where a node type is
  carried out by a shell script on one target and an Ansible playbook on another, both are
  expressible without a type per implementation technology.
- **One published artifact set serves several processors**, since the bindings that a processor
  cannot execute drop out rather than breaking the import.

## 6. What is not proposed

- **No change to how an implementation is described.** The implementation definition grammar is
  reused as it stands.
- **No obligation on a processor** to support any particular artifact type. A processor executes
  what it executes, and ignores the rest.
- **No change to the contract.** A binding cannot alter a signature, an operation's parameters, or
  anything else a consumer depends on.
- **No preprocessing.** Selecting an implementation is a processor decision at parse or run time,
  not a textual variant of the file.

## Alternatives considered

- **Allow a profile to refine a function declared in an imported profile.** Fewer new keynames,
  since the refinement rules already exist. Against it: it makes two definitions of one name legal,
  which is what the overlapping-definitions rule exists to prevent, and it inherits the positional
  addressing that #376 documents. A binding leaves name resolution alone.
- **Let a processor skip a signature whose implementation it cannot execute**, using the existing
  ordered signature list and first-match rule. This is the smallest possible change and gives
  alternative implementations for functions, but it requires every alternative to be written into
  the declaring profile, so the declaring profile must name every artifact type in advance. Useful
  on its own, and subsumed by this proposal.
- **Import under a namespace and declare a second function.** Legal today, and it changes every
  call site, so a template becomes specific to one processor.

## Method

The gap was found by taking the community `core` profile, whose function implementations are
Python artifacts, to a processor that executes custom functions as WebAssembly plugins. It is
described in community discussion
[#365](https://github.com/oasis-open/tosca-community-contributions/discussions/365). The operation
half is the same question, and is tracked in the community's open issues as the dynamic attachment
of implementation artifacts.
