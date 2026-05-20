# Azure Profile Node Types

TOSCA type definitions for Microsoft Azure resources.

## Node Type Hierarchy

```mermaid
classDiagram
    ubct_Principal <|-- Subscription
    ubct_PipPackage <|-- AzureCli
    ubct_IaasPlatform <|-- Region
    ubct_Root <|-- ResourceGroup
    ubct_KeyPair <|-- KeyPair
    ubct_Network <|-- VNet
    ubct_Subnet <|-- Subnet
    ubct_Root <|-- PublicIP
    ubct_SecurityGroup <|-- Nsg
    ubct_Port <|-- Nic
    ubct_VirtualCompute <|-- VirtualMachine
    ubct_VmImage <|-- Image
    kube_ManagedKubernetes <|-- Aks
```

Note: types prefixed with `ubct_` are base types from the `com.ubicity:2.5`
profile; `kube_` types come from `com.ubicity.kubernetes:2.5`.

## Resource Relationships

Azure resources are organized in two overlapping scopes: `Region` (deployment
target, provides credentials) and `ResourceGroup` (management container, groups
related resources under an `Subscription`).

```mermaid
classDiagram
    Subscription --> AzureCli : ManagedBy
    Region --> AzureCli : ManagedBy
    Region --> Subscription : AuthorizedUsing
    ResourceGroup --> Subscription : BelongsTo
    ResourceGroup --> Region : ContainedBy
    VNet --> Region : ContainedBy
    VNet --> ResourceGroup : BelongsTo
    Subnet --> VNet : ContainedBy
    Subnet --> ResourceGroup : BelongsTo
    PublicIP --> Region : ContainedBy
    PublicIP --> ResourceGroup : BelongsTo
    Nsg --> Region : ContainedBy
    Nsg --> ResourceGroup : BelongsTo
    KeyPair --> Region : ContainedBy
    KeyPair --> ResourceGroup : BelongsTo
    Nic --> Subnet : LinksTo
    Nic --> Nsg : ProtectedBy
    Nic --> PublicIP : AddressedBy
    Nic --> ResourceGroup : BelongsTo
    VirtualMachine --> Region : VirtualizedUsing
    VirtualMachine --> Nic : LinksTo
    VirtualMachine --> ResourceGroup : BelongsTo
    VirtualMachine --> Image : CreatedFrom
    Image --> Region : ContainedBy
    Image --> ResourceGroup : BelongsTo
    Aks --> Region : ContainedBy
    Aks --> ResourceGroup : BelongsTo
    Aks --> VNet : ContainedBy
    Aks --> Subnet : LinksTo
```
