# TOSCA Community Base Profile

The Base profile defines common types that can be used at the
Administrator View level abstraction and below.

## Artifact Types

### `Bash`

Artifacts of type `Bash` are shell scripts executed by the orchestrator.

|Property|Type|Mandatory|Description|
|---|---|---|---|
|`host`|`IPv4Socket`|no|The host on which to run the script, and the `ssh` port the orchestrator connects on. Port 22 is used where none is given. Where `host` is not set, the script runs locally on the orchestrator.|

How input values reach the script, which names are reserved, how output values
and errors come back: [artifact-conventions.md](../../docs/artifact-conventions.md).
