# Artifact Calling Conventions

**Status:** Current practice.
**Audience:** TOSCA Community
**Purpose:** State how values reach an implementation artifact and how results
come back. An artifact type that can implement something has to say this, or an
artifact written against it runs on one orchestrator and not another.

**Related documents:** [README](README.md) · [modeling-methodology](modeling-methodology.md) · [artifact-calling-convention-proposal](artifact-calling-convention-proposal.md) · [core profile](../core/README.md) · [technology base profile](../technology/base/README.md)

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

An operation's input values reach the artifact as **one document**, in a file
whose path is in the `TOSCA_INPUTS` environment variable. Each artifact type
reads that document in its own form: `Bash` reads shell assignments, `Python`
reads JSON.

- The document is keyed by the input names defined in the corresponding
  interface operation.
- `TOSCA_INPUTS` is set for every invocation and names a file that is always
  there, holding no inputs for an operation that declares none.
- An input that has no value — an optional input, or one whose value expression
  resolved to nothing — is not in the document.
- The file is readable by the account the artifact runs as and by nobody else.
  An artifact that runs on a remote host finds it beside the artifact in the
  staging directory, and it goes with that directory.
- The inputs are in the document only. The artifact's environment carries
  `TOSCA_INPUTS` and whatever the orchestrator sets for its own purposes, and no
  input value.

#### `Bash`: shell assignments

The file holds one `export name='value'` line per input, each value
single-quoted, so that sourcing it assigns every value and runs none:

```bash
load_inputs() {
    . "$TOSCA_INPUTS"
}
```

- Each input is the shell variable of its name with every `-` read as `_`, so an
  input named `mgmt-address` is `$mgmt_address` and the dash-case names TOSCA
  recommends are usable unchanged.
- Values of *TOSCA Primitive Types* and *TOSCA Special Types* are assigned in
  their TOSCA spelling — a boolean as `true` or `false`.
- Values of *TOSCA Complex Data Types* and *TOSCA Collection Types* are assigned
  as **JSON-encoded strings**. A script decodes them with
  [`jq`](https://jqlang.github.io/jq/) or equivalent.
- Sourcing the file needs nothing beyond the shell, so an artifact needs `jq`
  only where it reads a list or a map.

TOSCA permits names a shell variable cannot hold, and an operation implemented
by a `Bash` artifact can use only the names it can: ASCII letters, digits and
`_` once each `-` is read as `_`, not beginning with a digit, each mapping to a
distinct variable, and none of them a variable the shell or the orchestrator
depends on (*Reserved names*). An orchestrator reports an operation that breaks
this when the profile or the service template naming it is onboarded.

#### `Python`: a JSON document

The file holds a JSON object keyed by input name, in which each value keeps the
type the model gave it — a list arrives as a list and a map as a map, with
nothing to decode:

```python
import json, os
inputs = json.load(open(os.environ["TOSCA_INPUTS"]))
```

It is `{}` for an operation that declares no inputs, and every name TOSCA
permits for an input can be read from it.

### Reserved names

`TOSCA_INPUTS` is the orchestrator's, and an operation cannot declare an input
of that name. Beyond it, an orchestrator that sets environment variables of its
own **must document their names**, so that an artifact designer can avoid them
and, for a `Bash` artifact, so that no input is given a name that would replace
one. The names a shell holds for itself are unavailable to an input for the same
reason: `PATH`, `HOME`, `USER`, `IFS` and their like, the read-only ones such as
`UID`, and the ones a shell treats specially such as `RANDOM`.

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

- Arguments are passed as **one ordered list of values**, matching the
  `arguments` of the signature the function was called through. They are not
  named, and they are not passed as environment variables.
- The artifact defines an **entry point named after the TOSCA function**, taking
  that list as its single parameter: `to_uppercase` is implemented by a
  `to_uppercase` callable in `functions/to_uppercase.py`.
- The entry point returns a **single value**, of the type the signature's
  `result` declares. There are no named outputs.

```python
def to_uppercase(args):
    return args[0].upper()
```

A function whose signature declares no arguments is called with the list all the
same, and it is empty.

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
> satisfy a definition expecting the other. Removing the core copy, leaving the
> one that carries `host`, is tracked as I10 in the
> [open issues](../../../../governance/open-issues.md).

## What is still open

[artifact-calling-convention-proposal.md](artifact-calling-convention-proposal.md)
sets out the reasoning for one document in and the channels that were considered
for carrying it, and leaves two questions open: which channel returns an
operation's output values, since `stdout` is shared with everything else the
artifact prints; and whether the convention should be declared by the artifact
type rather than stated in prose here. The second is I10 in the
[open issues](../../../../governance/open-issues.md).
