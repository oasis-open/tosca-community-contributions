# One Document In

**Status:** Proposal — for discussion. The input half is a recommendation; the output half
states the problem and the options without settling it.
**Audience:** TOSCA Community.
**Purpose:** Replace the per-input environment variable convention with a single structured
document, so that an artifact written against a community artifact type runs unchanged on any
orchestrator that implements it.

**Related documents:** [core README](../core/README.md) ·
[technology base README](../technology/base/README.md) ·
[design-guide](design-guide.md)

---

## Why this is a profile question

The specification does not say how an orchestrator passes values to an implementation
artifact, and that is the right choice: it cannot know what a `Bash` artifact is, let alone
how to call one. But it means the contract has to live somewhere else, and the only place it
can live is the artifact type — which is profile territory.

Today it does not live there. `Bash` declares `host`; `Python` declares nothing at all.
Neither says how a value reaches the script or how a result comes back. Two orchestrators can
both implement `community.tosca.core:Bash` correctly and run the same script to different
effect, which is the definition of a type that is not portable.

## What goes wrong without it

The current convention — one environment variable per input, named after the input, primitives
passed raw and everything else JSON-encoded — has produced four distinct failures in one
downstream profile set. They are worth listing because each traces to the same cause.

- **A value can disagree with itself.** A boolean passed as a bare input and the same boolean
  nested inside a map went through different encoders and arrived spelled differently. Four
  provider flags tested for the wrong spelling and silently never fired; one of them left a
  cluster endpoint public when the template asked for private.
- **Absence is a magic string.** An input with no value arrives as the four characters `null`,
  so `[ -z "$x" ]` never fires. Five artifacts discovered this by hand and test for the
  literal.
- **The namespace is shared and unowned.** Inputs sit alongside the inherited host environment
  and whatever the orchestrator injects for itself. On a collision the orchestrator wins and
  the input is lost without a diagnostic.
- **Not every input name can be a variable name.** An input named `mgmt-address` cannot be an
  environment variable at all. This is latent rather than live, and it constrains the language
  from the outside: a naming convention in the profile is being set by a shell's identifier
  rules.

The common cause is that the environment is a flat `string → string` map that the artifact
does not own. Types are lost on the way in, so a second encoding is bolted on for the values
that cannot survive the first, and the two disagree.

## Proposal: one document, in one reserved variable

The orchestrator passes **all** input values as a single JSON document, in one environment
variable named `TOSCA_INPUTS`. Keys are input names; values keep the types the model gave
them.

```bash
name=$(jq -r '.name'    <<<"$TOSCA_INPUTS")
port=$(jq -r '.port'    <<<"$TOSCA_INPUTS")
tls=$( jq -r '.use_tls' <<<"$TOSCA_INPUTS")   # true or false, always
```

```python
inputs = json.loads(os.environ["TOSCA_INPUTS"])
```

This addresses every failure above. One encoding means a value cannot disagree with itself.
A document can express null, so absence needs no convention. One reserved name means one
possible collision instead of an open set. And an input name is a JSON key, so the profile's
naming is no longer constrained by shell syntax.

It is also the smallest change that does this. Nothing is staged, nothing is cleaned up, and
the remote path is untouched.

### What it costs, honestly

- **A parser becomes a hard dependency.** `jq` is needed today only for complex values; it
  would be needed for every input. Python and other languages have one built in.
- **A tighter size ceiling.** Linux caps a single environment string at 128 KiB. Today each
  input has its own ceiling and the total is bounded by `ARG_MAX`; with one variable the whole
  input set must fit in 128 KiB. An input set between those bounds works today and would not.
- **It is a breaking change** for every existing artifact, which argues for introducing it as a
  new artifact type rather than redefining `Bash` in place, so that both can exist while
  artifacts migrate.

## Alternatives considered

**A file, with its path in `TOSCA_INPUTS`.** Everything the single variable achieves, plus no
size ceiling and no exposure in the process table — a remote orchestrator that inlines the
environment onto the command line puts every input value where any local user on the target
can read it. It costs a file lifecycle, and for remote execution a staged file the
orchestrator must place and remove.

This proposal does not take that step, for a specific reason: the exposure it fixes is a
credential-model problem wearing a transport disguise. An input that carries secret *material*
rather than a reference to it is already a defect, and hiding it better in transit does not
make it correct. The other rows in the list above are genuine transport problems, and the
single variable fixes all of them.

**The migration between the two is one token**, which is what makes this a safe first step
rather than a fork in the road:

```bash
jq -r '.name' <<<"$TOSCA_INPUTS"   # variable
jq -r '.name'    "$TOSCA_INPUTS"   # file
```

**Inputs on `stdin`.** Equivalent to the file on every count that matters, and it avoids the
lifecycle entirely. It costs the second standard stream: with outputs already on `stdout`, a
script that reads its inputs from `stdin` has neither available for its own use — no prompting,
no piping into a command that reads `stdin`, no diagnostics without redirection.

## The output half is not settled

Outputs are returned on `stdout` and parsed as JSON or YAML. The technology base README already
names the flaw: *"any command output printed to `stdout` will interfere with the parsing of the
output string."* Every artifact must therefore redirect all incidental output somewhere else,
and one stray `echo` still corrupts the result. The idiom that works around this is repeated in
every script rather than provided by the contract.

None of the input proposals above changes this, including inputs-on-`stdin`, which makes it
worse by consuming the other stream.

Three options, none free:

| | fixes the interference | remote cost |
|---|---|---|
| Keep `stdout`, delimit the document with a sentinel | mostly — incidental output before the marker is safe | none; `stdout` already returns over the connection |
| A file, path in `TOSCA_OUTPUTS` | yes | the orchestrator must fetch the file back |
| A dedicated file descriptor | yes | descriptor inheritance across an `ssh` session is awkward |

The second is what GitHub Actions does with `$GITHUB_OUTPUT`, and it is the natural pair to a
file-based input. The first is the cheapest and keeps the remote path as it is. This proposal
raises the question rather than answering it.

## Open questions

1. Should the input document be JSON, or YAML, or either? A parser that reads YAML reads JSON;
   the reverse is not true.
2. Should the variable name carry a reserved prefix — `TOSCA_INPUTS` — or a profile-specific
   one? A prefix that the profile reserves makes collisions structurally impossible rather than
   a matter of documentation.
3. Should the convention be a property of the artifact type, so that a profile can define types
   with different conventions without ambiguity, rather than a rule stated once in prose?
4. Which of the three output channels, and is the sentinel form specific enough to standardize?
