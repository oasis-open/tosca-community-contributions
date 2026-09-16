# TOSCA Community Base Profile

The Base profile defines common types that can be used at the
Administrator View level abstraction and below.

## Relationship and Capability Types

This profile declares the three base relationship types, `ContainedBy`, `DependsOn` and
`AssociatesWith`, and the three capability types they target, `Container`, `Feature` and
`Partner`, for technology-specific and vendor-specific profiles. They have the meaning the
[abstract base profile](../../abstract/base/README.md#base-relationship-types) gives its own:
containment, dependency and association.

## Artifact Types

### `Bash`

Artifacts of type `Bash` are shell scripts executed by the orchestrator.

|Property|Type|Mandatory|Description|
|---|---|---|---|
|`host`|`Socket`|no|The host on which to run the script, and the `ssh` port the orchestrator connects on. Where `host` is not set, the script runs locally on the orchestrator.|

How input values reach the script, which names are reserved, how output values
and errors come back: [artifact-conventions.md](../../docs/artifact-conventions.md).
