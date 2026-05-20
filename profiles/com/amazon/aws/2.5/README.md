# AWS Profile Node Types

TOSCA type definitions for Amazon Web Services resources.

## Node Type Hierarchy

```mermaid
classDiagram
    ubct_Principal <|-- Account
    ubct_Software <|-- AwsCli
    ubct_IaasPlatform <|-- Region
    ubct_Network <|-- VirtualPrivateCloud
    ubct_Subnet <|-- Subnet
    ubct_Root <|-- ElasticIp
    ubct_KeyPair <|-- KeyPair
    ubct_SecurityGroup <|-- SecurityGroup
    ubct_Root <|-- InternetGateway
    ubct_Root <|-- RouteTable
    ubct_VirtualCompute <|-- Compute
    ubct_Port <|-- NetworkInterface
    ubct_VmImage <|-- Ami
    kube_ManagedKubernetes <|-- Eks
```

Note: types prefixed with `ubct_` are base types from the `com.ubicity:2.5`
profile; `kube_` types come from `com.ubicity.kubernetes:2.5`.

## Resource Relationships

```mermaid
classDiagram
    Account --> AwsCli : ManagedBy
    Region --> AwsCli : ManagedBy
    Region --> Account : AuthorizedUsing
    VirtualPrivateCloud --> Region : ContainedBy
    Subnet --> VirtualPrivateCloud : ContainedBy
    SecurityGroup --> VirtualPrivateCloud : ContainedBy
    InternetGateway --> VirtualPrivateCloud : ContainedBy
    RouteTable --> VirtualPrivateCloud : ContainedBy
    RouteTable --> InternetGateway : RoutesTo
    KeyPair --> Region : ContainedBy
    ElasticIp --> Region : ContainedBy
    Compute --> Region : VirtualizedUsing
    Compute --> KeyPair : AuthorizedUsing
    Compute --> SecurityGroup : ProtectedBy
    Compute --> Ami : CreatedFrom
    Ami --> Region : ContainedBy
    NetworkInterface --> Subnet : LinksTo
    NetworkInterface --> SecurityGroup : ProtectedBy
    NetworkInterface --> ElasticIp : AssociatedWith
    Compute --> NetworkInterface : LinksTo
    NetworkInterface --> Compute : BindsTo
    Eks --> Region : ContainedBy
    Eks --> VirtualPrivateCloud : ContainedBy
    Eks --> Subnet : LinksTo
    Eks --> SecurityGroup : ProtectedBy
```
