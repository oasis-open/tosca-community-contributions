# Google Cloud Profile Node Types

TOSCA type definitions for Google Cloud Platform resources.

## Node Type Hierarchy

```mermaid
classDiagram
    ubct_Principal <|-- Project
    ubct_InstallablePackage <|-- GCloudCli
    ubct_IaasPlatform <|-- Zone
    ubct_Network <|-- Network
    ubct_Subnet <|-- Subnet
    ubct_SecurityGroup <|-- FirewallRules
    ubct_VirtualCompute <|-- Instance
    ubct_VmImage <|-- Image
    kube_ManagedKubernetes <|-- Gke
```

Note: types prefixed with `ubct_` are base types from the `com.ubicity:2.5`
profile; `kube_` types come from `com.ubicity.kubernetes:2.5`.

## Resource Relationships

GCP credentials are project-scoped: `Zone` and `Network` require the
`Project` directly via the `credential` capability.

```mermaid
classDiagram
    Project --> GCloudCli : ManagedBy
    Zone --> GCloudCli : ManagedBy
    Zone --> Project : AuthorizedUsing
    Network --> Project : AuthorizedUsing
    Subnet --> Network : ContainedBy
    FirewallRules --> Network : ContainedBy
    Instance --> Zone : VirtualizedUsing
    Instance --> Subnet : LinksTo
    Instance --> FirewallRules : DependsOn
    Instance --> Image : CreatedFrom
    Gke --> Zone : ContainedBy
    Gke --> Network : ContainedBy
    Gke --> Subnet : LinksTo
```
