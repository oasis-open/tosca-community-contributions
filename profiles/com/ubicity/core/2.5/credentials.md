# Ubicity Core Profile

The Ubicity Core Profile defines types that are shared between
profiles at different levels of abstraction. It primarily defines base
capability types, base relationship types, common data types, and
common artifact types.

## Credentials

TOSCA v1.3 defined the following `Credential` data type:
```yaml
data_types:
  tosca.datatypes.Credential:
    derived_from: tosca.datatypes.Root
    description: >-
      The Credential type is a complex TOSCA data Type used when
      describing authorization credentials used to access network
      accessible resources.
    properties:
      protocol:
        type: string
        description: >-
          The optional protocol name.
        required: false
      token_type:
        type: string
        description: >-
          The required token type.
        default: password
      token:
        type: string
        description: >-
          The required token used as a credential for authorization or
          access to a networked resource.
      keys:
        type: map
        description: >-
          The optional list of protocol-specific keys or assertions.
        required: false
        entry_schema:
          type: string
      user:
        type: string
        description: >-
          The optional user (name or ID) used for non-token based
          credentials.
        required: false
```
The biggest issue with this data type is that it contains the
credential data directly, which means that these credentials will
likely be available in the representation graph. This forces
implementors to:

- recognize which data represent credentials
- encrypt those credential data before storing them in the
  representation graph

The TOSCA language does not include any functionality to help
implementors with this challenge. Specifically, there is not grammar
to specify which data are *sensitive* and may need to be encrypted.

To avoid these challenged, the Ubicity Core Profile defines the
following `Credential` data type instead:

```yaml
data_types:
  Credential:
    properties:
      user_name:
        type: string
        required: true
      token_file:
        type: string
        required: false
        description: >-
          Either token_file, key_file, or password_file must be
          provided.
      key_file:
        type: string
        required: false
        description: >-
          Either token_file, key_file, or password_file must be
          provided.
      password_file:
        type: string
        required: false
        description: >-
          Either token_file, key_file, or password_file must be
          provided.
```
This data type assumes that credential data are stored in files, and
that the Orchestrator passes credential file names rather than passing
credential data directly. Implementations that need those credentials
are responsible for extracting the credentials from the credential
files.

While this approach avoids storing credential data directly, it comes
with its own set of challenges:

- It assumes that credential files are available in the file system of
  the Orchestrator machine. In production environments, it is more
  likely that credentials are stored in a *credential vault* and
  retrieved using an interface exposed by that vault.
- It provides no helpful information to implementors about the file
  format in which those credentials are expected to be stored.

To address these limitations, I've been experimenting with the
following alternative approach:

- Rather than using properties of type `Credential`, I'd like to use
  *artifacts* to represent credentials.
- To support retrieving credentials from a *vault*, I'd like to use a
  TOSCA repository definition to represent that vault.
- Credential data themselves can be retrieve from the vault using the
  TOSCA `$get_artifact` function.
- Data type definitions for credential artifacts can provide
  information about the format in which data are stored, and can
  define properties to help with processing the information.

This approach runs into other roadblocks: many use cases require
credentials to be created dynamically during orchestration
(e.g. generate an SSH key for a virtual compute instance). I'd like to
store these newly created credentials in the same vault. TOSCA
currently does not define repository or artifact grammar that allows
me to do this in a general-purpose way.

