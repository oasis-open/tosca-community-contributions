# TOSCA Profiles

This directory contains a collection of TOSCA Profiles contributed by
users of the TOSCA language.

## What are TOSCA Profiles

A TOSCA Profile is a collection of TOSCA type definitions, supporting
artifacts, and (optionally) substituting service templates. Those
entities are grouped together into a *profile* because they relate to
a specific application domain or because they represent a specific
technology.

Profiles are a *TOSCA v2.0* feature. Using TOSCA v2.0, profile
designers define profiles by using the *profile* keyword to assign a
profile name to a collection of TOSCA definitions. Profile names are
expected to be unique and *well-known* to allow service designers to
import profiles by their *well-known profile name*.

## Profile Design Best Practices

### Profile Names

While the TOSCA standard does not specify a naming scheme for profile
names, we recommend as a best practice the use of the same *reverse
domain-name notation* that is typically used for Java modules. For
example, the following defines a TOSCA Version 2.0 profile that
defines the same types as those defined in TOSCA Simple Profile in
YAML Version 1.3:

```yaml
tosca_definitions_version: tosca_2_0
profile: org.oasis-open.simple:2.0
```

### Type Names

TOSCA Simple Profile in YAML v1.x uses long, dotted types names that
typically include an organization identifier as well as a key to
specify the *type* of type being defines. The following example is
taken from the TOSCA v1.3 specification:

```yaml
group_types:
  mycompany.mytypes.groups.placement:
    description: My company’s group type for placing nodes of type Compute
    members: [ tosca.nodes.Compute ]
```

While this pattern was likely proposed to avoid type name conflicts,
such conflicts can be avoided more elegantly using namespaces and
associated namespace prefixes introduced in TOSCA v2.0, and the use of
long, dotted type names should be avoided.

### TOSCA File Names

Another pattern that should be avoided is the organization of
different types of type definitions in different TOSCA files
(e.g. node type definitions go into a node_types.yaml file,
relationship types in relationship_types.yaml, etc.). Not only are
there few advantages to such a separation, it can actually create
circular import problems when the node_types.yaml file must import the
relationship_types.yaml file to define requirement definitions, but
the relationship_types.yaml file may need to import the
node_types.yaml file for node types used in `valid_target_node_types`.
