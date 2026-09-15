# TOSCA Core Profile

This profile defines general-purpose TOSCA types that are intended to
be shared by all other profiles.

## Data Types

Most data types here derive from a TOSCA primitive and add a validation clause, so a value is an
ordinary string or integer that has been checked. Three are complex types: `IPv4Socket`, composed
of two of the others, and the two credential references.

**The regular expressions avoid look-around assertions**, deliberately, so that they work in regex
engines that do not support them. Two consequences are documented on the types themselves: `Fqdn`
does not enforce the 253-character DNS name limit, and `Email` accepts most common addresses without
being fully compliant with RFC 5321 and RFC 5322.

### Structured encodings

- **`JSON`**, **`YAML`** — a string carrying a document in that format, validated by the
  corresponding function below. `YAML` is the type the `implementation-details` property uses to
  carry values across a substitution boundary, so any profile using that property depends on the
  YAML parser those functions need.

### Network addressing

- **`IPv4`** — a dotted-quad IPv4 address.
- **`Port`** — an integer from 0 to 65535. Zero is admitted because it is the conventional way to
  ask for an unspecified port; a URL cannot name it, which is why `HttpUrl` accepts only 1 to 65535.
- **`IPv4Socket`** — an address and a port together, as `ip-address` and `transport-port`.

### Names and addresses

- **`Email`** — an email address.
- **`Fqdn`** — a fully qualified domain name.
- **`HttpUrl`** — an HTTP or HTTPS URL whose host is `localhost`, an FQDN or an IPv4 address,
  optionally followed by a port and by a path, query or fragment built from the characters RFC 3986
  permits. Anchored at both ends, so the whole value must be a URL rather than merely begin with
  one.

### Identifiers

- **`GenericId`** — a string identifier with no constraint of its own. It exists to be derived from,
  by a type that adds the validation its identifiers need.
- **`AlphanumericId`** — letters and digits, any length.
- **`UUID`** — an RFC 4122 UUID, versions 1 through 5.
- **`UUIDRelaxed`** — the 8-4-4-4-12 hexadecimal form without the version and variant constraints.

### Credential references

A credential in a model is a reference to material, never the material itself: the material is
read on the host where it is used and never enters the representation graph.

- **`CredentialRef`** — `file`, the path to the file holding the material, and `name`, populated
  where the material needs an identifier: the principal to authenticate as, or the entry to
  select inside a file that holds several, where leaving it unset selects the file's own default.
- **`NamedCredentialRef`** — a `CredentialRef` whose `name` is required, for a credential that
  authenticates as a principal.

What kind of credential a value is does not live in the value. A node that needs credentials
declares a map of them keyed by kind, and each derived type narrows the keys to the kinds it
accepts. For credentials the orchestrator creates rather than references,
[credential-orchestration-proposal.md](../docs/credential-orchestration-proposal.md) proposes the
capability and node types that use these.

## Artifact Types

This profile declares two artifact types that can serve as implementations:

- **`Python`** — a Python script. It implements both operations and TOSCA
  functions, and the two have different calling conventions.
- **`Bash`** — a shell script, implementing operations.

How values reach an implementation and how results come back is in
[artifact-conventions.md](../docs/artifact-conventions.md), which is the single
place these are described. `Bash` is also declared in the
[technology base profile](../technology/base/README.md), which is the copy that
carries a `host` property; which copy stays is tracked as I10 in the
[open issues](../../../../governance/open-issues.md).

## Functions

This profile defines custom functions whose implementations are Python
files under [`functions/`](functions). The entry point in each file has
the same name as the TOSCA function.

Most of these implementations use the Python **standard library only**, so
a processor can execute them without provisioning anything. The two YAML
functions are the exception: `validate_yaml` and `decode_yaml` require a
**YAML parser** (PyYAML), which a processor must make available to function
implementations. `validate_yaml` is also the validation clause on the
`YAML` data type, so that dependency applies to any profile using that
type — including the `implementation-details` property in the
[base profile](../abstract/base).
