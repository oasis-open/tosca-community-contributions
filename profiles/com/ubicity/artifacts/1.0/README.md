# Artifacts Profile

## Artifact Processing Overview

TOSCA uses *artifacts* to provide implementations for the interface
operations associated with nodes and relationships.  These artifacts
are used as follows:

1. Each TOSCA artifact is *executed* by a corresponding *artifact
   processor* that is selected based on the artifact's type.
2. The artifact's *properties* are passed to the artifact processor to
   control the execution of the artifact (e.g., to specify the host on
   which a script is intended to be run).
3. In addition, *operation input values* must be passed on by the
   artifact processor to the artifact itself. The mechanism for how
   this is done is specific to each type of artifact and must be
   documented by the artifact type designer (and supported by the
   corresponding artifact processor implementation).
4. Similarly, artifact processing may result in *operation output
   values* that need to be returned to the orchestrator. The mechanism
   for how this is done is specific to each type of artifact and must
   be documented by the artifact type designer (and supported by the
   corresponding artifact processor implementation).
5. Processing artifacts may result in *execution errors* that need to
   be returned to the orchestrator. TOSCA currently does not provide a
   mechanism for profile designers to specify the possible error
   values that can be returned.

## Artifact Types
This profile defines the following artifact types:

### `Bash`
Artifacts of type `Bash` are shell scripts that are executed by the
Orchestrator.
#### Properties
Bash artifacts support the following properties:
|Property|Mandatory|Description|
|---|---|---|
|`host`|no|The (remote) host on which to execute the script. The orchestrator uses `ssh` to connect to remote hosts. If the `host` property is not set, the script is run locally on the Orchestrator host.|
|`user`|conditional|The name of the remote user account as which to execute the script. This account must have `sudo` privileges. This name must be specified if the `host` property is specified|
|`key_file`|conditional|The file system path to a file that contains the key to be used for establishing the `ssh` connection to the remote `host`. This path must be specified if the `host` property is specified.|
#### Input Values
The TOSCA specification is somewhat ambiguous about how input values
must be passed to the Bash scripts that provide interface operation
implementations. It states only that inputs values must be passed to
Bash artifacts as *environment variables*. The Ubicity artifact
processor for `Bash` artifacts uses the following conventions:
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

The Ubicity Orchestrator also passes a `LOG_FILE` environment variable
to all Bash artifacts that contains the file system path to the
Ubicity log file. By default, this variable contains the value
`/var/log/ubicity/ubicity.log`.

#### Output Values
The TOSCA specification does not clearly specify how output values
must be returned by the Bash scripts to the orchestrator.  Ubicity
uses the following approach:

- Output values are returned using `stdout`.
- Output values are returned as a single JSON-encoded string. The
  orchestrator decodes this string into separate output values.
- Names of the output values in the JSON string must match the names
  used in the corresponding interface operation output definitions.

This approach is very brittle, since any command output printed to
`stdout` will interfere with the parsing of the output string. Bash
artifact designers must make sure that all command output is directed
to the Ubicity log file instead.

> Ubicity is currently exploring alternative mechanisms for returning
> output values.

### `Python`
Artifacts of type `Python` are Python 3 scripts that are executed by
the Orchestrator using the `python3 <artifact_file>` command.
#### Properties
Python artifacts currently do not support any properties. This means
that unlike shell scripts, Python scripts cannot currently be executed
on remote hosts. Instead, they are executed on the Orchestrator host.
#### Inputs
Just as with Bash artifacts, input values are passed to Python scripts
using environment variables. The same encoding mechanisms are used as
for Bash scripts.
#### Outputs
Just as with Bash artifacts, output values are return as a
JSON-encoded string to `stdout`.
### `Ansible`
The Ubicity Orchestrator provides a simple integration with Ansible:
artifacts of type `Ansible` are *Ansible playbooks* that are run by
the Orchestrator using the `ansible-playbook` command.
#### Properties
Ansible playbooks that are used as TOSCA implementation artifacts must
not reference an inventory, since the Ubicity Orchestrator will
automatically create temporary inventory files based on the property
values specified for the Ansible artifact. To enable this
functionality, the `hosts` section in the Ansible playbook should look
as follows:
```
- hosts: all
  gather_facts: false
```
Ansible inventory files are populated with information based on the
following `Ansible` artifact type properties:

|Property|Mandatory|Description|
|---|---|---|
|`host`|no|The host name of the *managed node* controlled by the Ansible playbook. This name is used to set the value of the `ansible_host` variable. The orchestrator assumes that `ssh` will be used to connect to remote hosts. If the `host` property is not set, the `ansible_host` variable is set to `localhost` and the `ansible_connection` variable is set to `local`.|
|`user`|conditional|The name of the remote user account as which to connect to the managed node. Is is used to set the value of the `ansible_user` variable. This name must be specified if the `host` property is specified|
|`key_file`|conditional|The file system path to a file that contains the key to be used for establishing the `ssh` connection to the remote `host`. It is used to set the value of the `ansible_ssh_private_key_file` variable. This path must be specified if the `host` property is specified.|
#### Input Values
Interface operation inputs are used as the values for *template
variables* in the Ansible playbooks. They are written to a temporary
*inputs* file (in YAML format) which is then passed to the
`ansible-playbook` command as a command line argument. The names of
the inputs defined for an interface operation must match the names of
the template variables in the playbook.
#### Output Values

Ansible playbooks return output values using `set_stats` and are
retrieved by the orchestrator as `global_custom_stats`. The keys in
the `data` dictionary of `set_stats` must match the names of the
outputs defined in the interface operations. The following example
shows a playbook that returns a `my_attribute` output:
```
- hosts: all
  gather_facts: false

  tasks:
    - name: set outputs
      set_stats:
        data:
          my_attribute: my_custom_attribute_value
```
### `Terraform`
The Ubicity Orchestrator includes a *Terraform Artifact Processor*
that provides a simple integration with Terraform. Artifacts of type
`Terraform` are *Terraform configuration files* that are processed by
the Orchestrator using the `terraform` command. To be usable by the
Ubicity Orchestrator, Terraform configurations must consist of a
single file that contains all the necessary information for Terraform
to process the configuration. This includes among other things:
- Information about the provider.
- Terraform resource definitions.
- Variable definitions.
- Output definitions.

The Terraform Artifact Processor performs the following steps:
1. The artifact processor first copies the Terraform configuration
   file into a temporary directory and executes `terraform init` in
   that directory to retrieve the appropriate providers. Subsequent
   Terraform commands will be executed in that same directory.
2. Since Terraform uses the same configuration file for creation,
   updates, and deletion, TOSCA artifacts of type `Terraform` must
   define a property value that specifies which Terraform command is
   intended to be executed.
3. Terraform uses the Terraform *state file* created by the initial
   deployment as context for subsequent updates to the service or for
   deletion of that service. The Terraform artifact processor keeps
   track of these state files as long as the service is active by
   storing them on a backend service. To avoid naming conflicts, TOSCA
   artifacts of type `Terraform` must define a unique property value
   that is used as the *base name* of the Terraform state file on the
   backend. The Terraform Artifact Process deletes state files when
   the TOSCA service is deleted.

#### Properties
The Terraform artifact type support the following properties:
|Property|Mandatory|Description|
|---|---|---|
|`action`|yes|One of `create`, `update`, or `delete`.|
|`tfstate`|yes|A unique string that is used as the basename for the Terraform state file on the backend service|

#### Input Values
The Terraform configuration must define variables for each of the
inputs defined by the operation for which the Terraform file is an
implementation. Each variable must have the same symbolic name and the
same type as the corresponding operation input. The following example
shows such a variable definition:
```
variable "vpc_name" {
  type = string
}
```
At deployment time, the Orchestrator creates a `terraform.tfvars.json`
file using the provided input values.

#### Output Values
The Terraform configuration must define outputs for each of the
outputs defined by the operation for which the Terraform file is an
implementation. Each output must have the same symbolic name as the
corresponding operation output and must return a value that is
compatible with the type defined by the operation output. At
deployment time, the artifact processor uses the `terraform output`
command to return the corresponding output values back to the
Orchestrator. The following example shows such a variable definition:
```
output "vpc_id" {
  description = "The ID of the VPC instance"
  value       = aws_vpc.ubicity.id
}
```

### `Deployment`
Artifacts of type `Deployment` represent files that are expected to be
deployed to a specific file system location on a specific host.
#### Properties
Deployment artifacts support the following properties:
|Property|Mandatory|Description|
|---|---|---|
|`host`|no|The (remote) host on which to deploy the file. The orchestrator uses `ssh` to connect to remote hosts. If the `host` property is not set, the artifact is copied locally on the Orchestrator host.|
|`directory`|yes|The directory in which to deploy the file.|
|`user`|conditional|The name of the remote user account as which to connect to the remote host. This account must have write permissions to the specified directory. This name must be specified if the `host` property is specified|
|`key_file`|conditional|The file system path to a file that contains the key to be used for establishing the `ssh` connection to the remote `host`. This path must be specified if the `host` property is specified.|
#### Input Values
Artifacts of type `Deployment` currently do not support inputs.
> It is conceivable that subclasses of this artifact type might
> represent *template* files that expect values for templated
> variables in the file.

### `Tar`

Artifacts of type `Tar` tarfiles that are expected to be deployed and
*untarred* in a specific file system location on a specific host. The
`Tar` artifact type derives from the `Deployment` artifact type.

#### Properties
`Tar` artifacts do not define additional properties beyond those
supported by `Deployment` artifacts.
