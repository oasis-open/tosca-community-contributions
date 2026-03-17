# TOSCA Community Base Profile

The Base profile defines common types that can be used at the
Administrator View level abstraction and below.

## Artifact Types

### `Bash`
Artifacts of type `Bash` are shell scripts that are executed by the
Orchestrator.
#### Properties
Bash artifacts support the following properties:
|Property|Type|Mandatory|Description|
|---|---|---|---|
|`host`|IPv4Address|no|Specifies the (remote) host on which to execute the script and the optional `ssh` port used by the orchestrator to connect to remote hosts. If the port is not specified, the default port 22 is used. If the `host` property is not set, the script is run locally on the Orchestrator host.|

#### Input Values

The `Bash` artifact uses the following conventions for passing input
values to scripts:

- Inputs values are passed to Bash scripts as *environment
  variables*
- Multiple environment variables are used, one for each input defined
  in the corresponding interface operation.
- Each environment variable has the same name as the input name used in
  the corresponding interface or operation input definition.
- Values for *TOSCA Primitive Types* or *TOSCA Special Types* are passed
  directly without encoding.
- Values for *TOSCA Complex Data Types* or for *TOSCA Collection Types*
  (i.e., lists and maps) are passed as JSON-encoded strings. Bash scripts
  must decode these values (e.g., using
  [`jq`](https://jqlang.github.io/jq/)) before they can be used.

> A more streamlined approach could use a single environment variable
> that contains a JSON encoded string for all input values.

#### Output Values
Bash scripts return output values to the orchestrator as follows:

- Bash scripts must print output values to `stdout`.
- Output values can be returned as a single JSON-encoded string or as
  YAML. The orchestrator decodes the JSON string or the YAML into
  separate output values.
- Names of the output values in the JSON string must match the names
  used in the corresponding interface operation output definitions.

This approach is somewhat brittle, since any command output printed to
`stdout` will interfere with the parsing of the output string. Bash
artifact designers must make sure that all command output is directed
to the Ubicity log file instead.

#### Errors
Succesful execution of Bash scripts results in a return code value of
`0`. Non-zero return codes indicate an error.

> This artifact type definition should include conventions for return
  code values to indicate different types of errors.

