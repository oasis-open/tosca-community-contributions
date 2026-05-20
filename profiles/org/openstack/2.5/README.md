# OpenStack Profile Node Types

TOSCA type definitions for OpenStack resources.

## Node Type Hierarchy

```mermaid
classDiagram
    ubct_Principal <|-- Project
    ubct_PipPackage <|-- OpenstackCli
    ubct_IaasPlatform <|-- Region
    ubct_KeyPair <|-- KeyPair
    ubct_VirtualCompute <|-- Compute
    ubct_Port <|-- Port
    ubct_Network <|-- Network
    ubct_Subnet <|-- Subnet
    ubct_VmImage <|-- Image
```

Note: types prefixed with `ubct_` are base types from the `com.ubicity:2.5` profile.

## Resource Relationships

```mermaid
classDiagram
    Project --> OpenstackCli : ManagedBy
    Region --> OpenstackCli : ManagedBy
    Region --> Project : AuthorizedUsing
    Network --> Region : ContainedBy
    Subnet --> Network : ContainedBy
    KeyPair --> Region : ContainedBy
    Port --> Subnet : LinksTo
    Port --> Compute : BindsTo
    Compute --> Region : VirtualizedUsing
    Compute --> KeyPair : AuthorizedUsing
    Compute --> Port : LinksTo
    Compute --> Image : CreatedFrom
    Image --> Region : ContainedBy
```
