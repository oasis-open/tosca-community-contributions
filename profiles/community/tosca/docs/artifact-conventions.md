# Artifact Calling Conventions

**Status:** Current practice.
**Audience:** TOSCA Community
**Purpose:** State how values reach an implementation artifact and how results
come back. An artifact type that can implement something has to say this, or an
artifact written against it runs on one orchestrator and not another.

**Related documents:** [README](README.md) · [design-guide](design-guide.md) · [artifact-calling-convention-proposal](artifact-calling-convention-proposal.md) · [core profile](../core/README.md) · [technology base profile](../technology/base/README.md)

---

## Two conventions, not one

An artifact can implement two different things, and the contracts differ:

| | operation implementation | function implementation |
|---|---|---|
| **in** | named values, one per operation input | an ordered list of arguments |
| **out** | named values, one per operation output | a single value |
| **selected by** | the operation being implemented | an entry point named after the function |

> The difference is not about how an orchestrator invokes the artifact — in its
> own interpreter or as a subprocess — which is an implementation choice and not
> part of the contract. It is that an operation exchanges *named* values in both
> directions while a function takes *positional* arguments and returns *one*
> result. An artifact written for one cannot serve as the other.

## The operation convention

### Input values

- Input values are passed as **environment variables**, one for each input
  defined in the corresponding interface operation, each named after the input.
- Values of *TOSCA Primitive Types* and *TOSCA Special Types* are passed
  directly, in their TOSCA spelling — a boolean arrives as `true` or `false`.
- Values of *TOSCA Complex Data Types* and *TOSCA Collection Types* are passed
  as **JSON-encoded strings**. A shell script decodes them before use, with
  [`jq`](https://jqlang.github.io/jq/) or equivalent.
- An input that has no value — an optional input, or one whose value expression
  resolved to nothing — is passed as the four characters `null`. This is not the
  same as an empty string, which is passed as an empty variable, so a script can
  tell the two apart. A script that treats "no value" and "empty" alike should
  test for both.

### Reserved names

Input values share a namespace with any environment variable the orchestrator
sets for its own purposes, and with the environment the script inherits from the
host it runs on. Two consequences:

- An orchestrator that sets its own variables **must document their names**, so
  that artifact designers can avoid declaring operation inputs that collide with
  them. Where a collision does occur, the orchestrator's value wins and the input
  is silently lost.
- Names that are conventionally significant to a shell — `PATH`, `HOME`, `USER`,
  `IFS` and their like — should not be used as input names.

> Reserving a prefix for orchestrator-set variables would make collisions
> structurally impossible rather than a matter of documentation and care.
> Adopting one is a breaking change for existing artifacts, so it is noted here
> as a direction rather than a rule.

### Output values

- Output values are printed to **`stdout`**, as a single JSON-encoded string or
  as YAML. The orchestrator decodes it into separate output values.
- The names in that document must match the names in the operation's output
  definitions.

This is brittle: any command output printed to `stdout` interferes with parsing.
An artifact must direct command output to the orchestrator's log instead.

### Errors

A return code of `0` indicates success. A non-zero return code indicates an
error.

> Conventions for which non-zero codes indicate which kinds of error are not
> defined.

## The function convention

- Arguments are passed as an **ordered list of values**, matching the
  `arguments` of the signature the function was called through. They are not
  named, and they are not passed as environment variables.
- The artifact returns a **single value**, of the type the signature's `result`
  declares. There are no named outputs.
- The artifact defines an **entry point named after the TOSCA function**:
  `to_uppercase` is implemented by a `to_uppercase` callable in
  `functions/to_uppercase.py`.

## The runtime environment

What an implementation may assume about its runtime *is* part of the contract,
and is currently unstated. The functions in the core profile use the Python
standard library only, with one exception: `validate_yaml` and `decode_yaml`
require a YAML parser, and so depend on a package the orchestrator must make
available. Because `validate_yaml` is the validation clause on the `YAML` data
type, that dependency reaches any profile using the type.

> Conventions for declaring an implementation's package dependencies, and for
> the language version an implementation may assume, are open.

## Which artifact type follows which

| artifact type | operation | function | declared in |
|---|---|---|---|
| `Python` | yes | yes | `community.tosca.core` |
| `Bash` | yes | — a function is implemented by a callable the processor invokes, which a shell script is not | `community.tosca.core` and `community.tosca.technology.base` |

The `Bash` type declared in the technology base profile additionally carries a
`host` property: where it is set, the script runs on that host over `ssh`, on
port 22 unless the property gives another; where it is unset, the script runs
locally on the orchestrator.

> `Bash` being declared in two profiles is a defect rather than a design. TOSCA
> typing is nominal, so the two are distinct types and an artifact of one cannot
> satisfy a definition expecting the other. Section 2.9 of the
> [abstract-profile proposal](abstract-profile-proposed-changes.md) proposes
> removing the core copy, leaving the one that carries `host`.

## Changing these conventions

A proposal to replace the per-input environment variable with a single
structured document is in
[artifact-calling-convention-proposal.md](artifact-calling-convention-proposal.md).
