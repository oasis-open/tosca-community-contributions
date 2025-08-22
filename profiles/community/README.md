# TOSCA Community Profiles

This directory is intended to track profiles created by the TOSCA
Community.

> The community needs to decide on a naming convention for these
  profiles.

## Objectives

The goal for these community profiles is to combine *best of breed*
type definitions created by various TOSCA projects over the
years. Most of these projects have used the TOSCA Simple Profile in
YAML v1.3 type definitions as a starting point and have extended these
definitions to satisfy project-specific objectives. As a result, it is
likely that there are sufficient similarities between these profiles
that should allow them to be harmonized. However, there are likely
also significant differences, specifically:

- differences in the target platforms on which components modeled by
  node types are intended to be deployed (e.g. IaaS clouds, PaaS
  platforms, Kubernetes clusters, dedicated compute devices, etc.)
- differences in the deployment technologies used to interact with the
  physical resources (e.g., Ansible, Terraform, Bash, etc.)

The community profiles should include sufficient variability to
accommodate these differences.

## Approach

Common community profiles will be created using the following process:

1. *Document*: For each of the profiles under consideration, document
   the TOSCA node type hiearchies.
2. *Categorize*: Define common categories into which to separate the
   various node type definitions.
3. *Harmonize*: Extract common node type hierarchies for each of the
   defined categories.
4. *Integrate*: Define common capabilities and requirements that
   define the integration points between the defined node types.
5. *Configure*: Define common properties and attributes.
6. *Implement*: Define mechanisms for overlaying various
   deployment technologies for the community profiles.

## Document

Common community profiles will be based on TOSCA type definitions that
have been created in the context of various TOSCA implementation
projects. So far, the following have been identified:

- [TOSCA Simple Profile in YAML v1.3](https://github.com/oasis-open/tosca-community-contributions/tree/master/profiles/org/oasis-open/simple/1.3)
- [TOSCA Simple Profile Non-Normative](https://github.com/oasis-open/tosca-community-contributions/tree/master/profiles/org/oasis-open/non-normative/1.3)
- [EDMM](https://github.com/UST-EDMM/modeling-repository/)
- [OpenTOSCA](https://github.com/OpenTOSCA/tosca-definitions-common)
- [Vintner](https://vintner.opentosca.org/normative/)
- [DeMAF](https://github.com/UST-DeMAF/demaf-type-definitions)
- [XLAB Steampunk AWS EC2](https://github.com/oasis-open/tosca-community-contributions/tree/master/profiles/si/steampunk/aws/ec2)
- [Yorc](https://github.com/ystia/yorc/tree/develop/data/tosca)
- [Ystia](https://github.com/ystia/forge/tree/develop/org/ystia)
- [Alien4Cloud](https://github.com/alien4cloud/csar-public-library/tree/develop/org/alien4cloud)
- [Radon particles](https://github.com/radon-h2020/radon-particles)
- [Ubicity](https://github.com/lauwers/tosca-community-contributions/tree/master/profiles/com/ubicity)
- [Cloudify](https://github.com/cloudify-cosmo/cloudify-manager/blob/master/resources/rest-service/cloudify/types/types.yaml)
- other?

> Most of these type definitions will need to be converted to TOSCA v2.0

This section shows node type hierarchies for each of these profiles

### TOSCA Simple Profile in YAML v1.3

The TOSCA Simple Profile in YAML specification defines both normative
and non-normative types. Since the non-normative type definitions
derive from the normative types, normative and non-normative types are
combined in the following class diagram:

> In order the improve readability of the diagram, the leading
  `tosca.nodes.` prefixes are omitted from the node type names.

```mermaid
classDiagram
    class Root
    Root <|-- Abstract.Compute
    Abstract.Compute <|-- Compute
    Root <|-- SoftwareComponent
    SoftwareComponent <|-- WebServer
    Root <|-- WebApplication
    SoftwareComponent <|-- DBMS
    Root <|-- Database
    Root <|-- Abstract.Storage
    Abstract.Storage <|-- Storage.ObjectStorage
    Abstract.Storage <|-- Storage.BlockStorage
    SoftwareComponent <|-- Container.Runtime
    Root <|-- Container.Application
    Root <|-- LoadBalancer
    Root <|-- network.Network
    Root <|-- network.Port
    Database <|-- Database.MySQL
    DBMS <|-- DBMS.MySQL
    WebServer <|-- WebServer.Apache
    WebApplication <|-- WebApplication.WordPress
    WebServer <|-- WebServer.Nodejs
    Container.Runtime <|-- Container.Runtime.Docker
    Container.Application <|-- Container.Application.Docker
```
### EDMM
EDMM Provides a declarative model describing the components to be
deployed, their configurations, required artifacts, and relations
among them. The resulting EDMM model is independent of any specific
deployment technology and can be exported from an EDMM-enabled
modeling tool or created directly using a text editor according to the
respective YAML specification. This model can be fed into the EDMM
Transformation and Deployment Framework.

TOSCA v2.0 versions of the node types defined by EDMM can be found in
[edmm.yaml](edmm.yaml). They are organized in the following node type
hiearchy:
```mermaid
classDiagram
    class Compute
    class Database
    class Platform
    class Software_Component
    class Web_Application
    SaaS <|-- Auth0
    DBaaS <|-- AWS_Aurora
    PaaS <|-- AWS_Beanstalk
    Platform <|-- DBaaS
    Software_Component <|-- DBMS
    Web_Server <|-- Go
    Software_Component <|-- MOM
    DBMS <|-- MongoDB
    Database <|-- MongoDB-Schema
    Database <|-- MySQL_Database
    DBMS <|-- MySQL_DBMS
    Web_Server <|-- NodeJS
    Platform <|-- PaaS
    Web_Application <|-- PetClinic
    MOM <|-- RabbitMQ
    Platform <|-- SaaS
    Web_Server <|-- SpringBoot
    Web_Server <|-- Tomcat
    Software_Component <|-- Web_Server
```
### OpenTOSCA

OpenTOSCA defines common TOSCA types for VMs, cloud providers, and
runtimes that are intended to be consumed by the OpenTOSCA Container.
TOSCA v2.0 versions of the node types defined by OpenTOSCA can be
found in [open-tosca.yaml](open-tosca.yaml). They are organized in the
following node type hiearchy:

```mermaid
classDiagram
    class ApacheWebServer_w1
    class AWS_w1
    class Boto3_latest-w1
    class BPMN-Workflow_w1
    class Camunda_7.14.0-w1
    class Channel
    class DockerEngine_w1
    class EC2-w1
    class Gunicorn_20.1.0-w1
    class GunicornApp_w1
    class KVM_QEMU_Hypervisor_w1
    class MariaDB_10-w1
    class MariaDBMS_10-w1
    class Mosquitto_2.0-w1
    class NGINX_latest-w1
    class OpenStack_15-Train-w1
    class OpenStack_22-Victoria-w1
    class Python_3-w1
    class PythonApp_3-w1
    class RabbitMQ_3.10-w1
    class Redis_6-w1
    class VSphere_5.5-w1
    WebApplication <|-- ApacheApp_w1
    ContainerApplication <|-- DockerContainer_w1
    SoftwareComponent <|-- Java_11-w1
    SoftwareComponent <|-- Java_8-w1
    Compute <|-- KVM_QEMU_VM_w1
    Database <|-- MariaDB_10-w2
    DBMS <|-- MariaDBMS_10-w2
    MySQL-DBMS_w1 <|-- MySQL-DBMS_5.7-w1
    MySQL-DBMS_w1 <|-- MySQL-DBMS_8.0-w1
    DBMS <|-- MySQL-DBMS_w1
    Database <|-- MySQL-DB_w1
    WebApplication <|-- NGINX-Application_w1
    Compute <|-- OperatingSystem_w1
    WebApplication <|-- SpringWebApp_w1
    Tomcat_w1 <|-- Tomcat_7-w1
    Tomcat_w1 <|-- Tomcat_8-w1
    Tomcat_w1 <|-- Tomcat_9-w1
    WebApplication <|-- TomcatApplication_WAR-w1
    WebServer <|-- Tomcat_w1
    Channel <|-- Topic
    DockerContainer_w1 <|-- UbuntuContainer_20.04-w1
    OperatingSystem_w1 <|-- Ubuntu-VM_16.04-w1
    OperatingSystem_w1 <|-- Ubuntu-VM_18.04-w1
    OperatingSystem_w1 <|-- Ubuntu-VM_20.04-w1
```
### Vintner

OpenTOSCA Vintner is a TOSCA preprocessing and management layer that
is able to deploy applications based on TOSCA orchestrator
plugins. Preprocessing includes the modeling of different deployment
variants inside a single deployment model.

Vintner defines two TOSCA profiles: the TOSCA Vintner Core Profile and
the TOSCA Vintner Extended Profile. Since the Extended Profile types
leverage the Core Profile types, they are combined into the following
diagram:

```mermaid
classDiagram
    node <|-- cloud.provider
    node <|-- cloud.service
    node <|-- software.component
    software.component <|-- service.component
    software.component <|-- software.runtime
    software.runtime <|-- container.runtime
    node <|-- machine
    machine <|-- local.machine
    machine <|-- remote.machine
    remote.machine <|-- virtual.machine
    remote.machine <|-- physical.machine
    node <|-- database
    database <|-- relational.database
    software.component <|-- dbms
    dbms <|-- relational.dbms
    software.component <|-- cache
    node <|-- storage
    storage <|-- block.storage
    storage <|-- object.storage
    storage <|-- file.storage
    node <|-- ingress
    software.runtime <|-- nodejs.runtime
    service.component <|-- nodejs.service.component
    service.component <|-- reactjs.service.component
    software.runtime <|-- python.runtime
    service.component <|-- python.service.component
    service.component <|-- go.service.component
    software.runtime <|-- java.runtime
    service.component <|-- java.service.component
    software.runtime <|-- dotnet.runtime
    service.component <|-- csharp.service.component
    service.component <|-- binary.service.component
    cloud.provider <|-- gcp.provider
    cloud.service <|-- gcp.service
    gcp.service <|-- gcp.cloudrun
    gcp.service <|-- gcp.cloudsql
    gcp.service <|-- gcp.appengine
    gcp.service <|-- gcp.appenginereporting
    gcp.service <|-- gcp.cloudbuild
    gcp.service <|-- gcp.kubernetesengine
    gcp.service <|-- gcp.cloudstorage
    gcp.service <|-- gcp.memorystore
    container.runtime <|-- docker.engine
    cloud.service <|-- kubernetes.cluster
    cloud.provider <|-- openstack.provider
    relational.dbms <|-- mysql.dbms
    relational.database <|-- mysql.database
    service.component <|-- minio.server
    cache <|-- redis.server
```

### DeMAF

Deployment-Model Abstraction Framework (DeMAF) is a tool that enables
transforming technology-specific deployment models using Terraform,
Kubernetes, etc. into technology-agnostic deployment models using the
Essential Deployment Metamodel (EDMM). DeMAF defines the following
node types:

> In order the improve readability of the diagram, the leading
  `demaf.nodetypes.` prefixes are omitted from the node type names.

```mermaid
classDiagram
    class BaseType
    BaseType <|-- CloudProvider
    BaseType <|-- ContainerPlatform
    SoftwareApplication <|-- DatabaseSystem
    ContainerPlatform <|-- DockerEngine
    ContainerPlatform <|-- KubernetesCluster
    BaseType <|-- localhost-type
    SoftwareApplication <|-- MessageBroker
    BaseType <|-- SoftwareApplication
    BaseType <|-- Storage
```

### XLAB Steampunk AWS EC2
The XLAB Steampunk AWS EC2 profile is intended to be a complete
library to interface with EC2. It defines the following types:

```mermaid
classDiagram
    Compute <|-- aws.Instance
    Root <|-- aws.InternetGateway
    Root <|-- aws.KeyPair
    Root <|-- aws.NatGateway
    Root <|-- aws.RouteTable
    Root <|-- aws.SecurityGroup
    Root <|-- aws.Subnet
    Root <|-- aws.VPC
    Root <|-- aws.VPCAddress
```

### Radon particles

Defines TOSCA types for application runtimes, computing resources, and
FaaS platforms in the form of abstract as well as deployable modeling
entities. The repository also comprises RADON's FaaS abstraction layer
that provides several TOSCA definitions to deploy a particular FaaS
application component to different cloud providers.

> To be provided

### Ystia/Alien4Cloud/Yorc

Ystia is an open source project (under OW2) that includes the
Alien4Cloud and Yorc technologies. Alien4Cloud is a graphical
front-end for designing and managing cloud applications. It is not an
orchestrator, but rather it requires a backend orchestrator for
deploying applications. Yorc (Ystia Orchestrator) is the default
orchestrator used by Alien4Cloud. Yorc is designed to support multiple
infrastructures (VMs, containers, Kubernetes, etc.).

> For reasons that are unclear, the Yorc and Alien4Cloud github
repositories each define their own TOSCA types In addition, there is a
separate Ystia repository that also defines TOSCA types. We need to
understand the motivation behind this separation as well as the
relationships between these different types.

#### Yorc
Yorc defines the following TOSCA types, many of which derived from the
Simple Profile types:

```mermaid
classDiagram
    yorc.Compute <|-- yorc.aws.Compute
    Network <|-- yorc.aws.PublicNetwork
    BlockStorage <|-- yorc.aws.EBSVolume
    yorc.Compute <|-- yorc.google.Compute
    Network <|-- yorc.google.Subnetwork
    Network <|-- yorc.google.PrivateNetwork
    Root <|-- yorc.google.Address
    BlockStorage <|-- yorc.google.PersistentDisk
    yorc.Compute <|-- yorc.hostspool.Compute
    yorc.Compute <|-- yorc.openstack.Compute
    BlockStorage <|-- yorc.openstack.BlockStorage
    Root <|-- yorc.openstack.FloatingIP
    Network <|-- yorc.openstack.Network
    Root <|-- yorc.openstack.ServerGroup
    yorc.Compute <|-- yorc.slurm.Compute
    org.alien4cloud.nodes.Job <|-- yorc.slurm.Job
    yorc.slurm.Job <|-- yorc.slurm.SingularityJob
    Compute <|-- yorc.Compute
    Root <|-- org.alien4cloud.nodes.Job
```

In addition, Yorc defines a collection of Kubernetes-related TOSCA
types that are based on Alien4Cloud type definitions.

```mermaid
classDiagram
    org.alien4cloud.kubernetes.api.types.DeploymentResource <|-- yorc.nodes.kubernetes.api.types.DeploymentResource
    org.alien4cloud.kubernetes.api.types.StatefulSetResource <|-- yorc.nodes.kubernetes.api.types.StatefulSetResource
    org.alien4cloud.kubernetes.api.types.JobResource <|-- yorc.nodes.kubernetes.api.types.JobResource
    org.alien4cloud.kubernetes.api.types.ServiceResource <|-- yorc.nodes.kubernetes.api.types.ServiceResource
    org.alien4cloud.kubernetes.api.types.SimpleResource <|-- yorc.nodes.kubernetes.api.types.SimpleResource
```

#### Ystia

```mermaid
classDiagram
    nodes.SoftwareComponent <|-- mongodb.linux.ansible.nodes.MongoDB
    org.alien4cloud.consul.pub.nodes.ConsulAgent <|-- yorc.experimental.consul.pub.nodes.Consul
    yorc.experimental.consul.pub.nodes.Consul <|-- yorc.experimental.consul.pub.nodes.ConsulServer
    yorc.experimental.consul.pub.nodes.Consul <|-- yorc.experimental.consul.pub.nodes.ConsulAgent
    yorc.experimental.consul.pub.nodes.ConsulServer <|-- yorc.experimental.consul.linux.ansible.nodes.ConsulServer
    yorc.experimental.consul.pub.nodes.ConsulAgent <|-- yorc.experimental.consul.linux.ansible.nodes.ConsulAgent
    SoftwareComponent <|-- ntp.pub.nodes.NtpServer
    ntp.pub.nodes.NtpServer <|-- ntp.ansible.nodes.NtpServer
    SoftwareComponent <|-- ntp.ansible.nodes.NtpClient
    Container.Application.DockerContainer <|-- alien.docker.nodes.Alien
    kibana.linux.bash.nodes.KibanaDashboard <|-- samples.hybrid-demo.cost-computing-dashboard.nodes.CostComputingJobDashboard
    yorc.nodes.slurm.SingularityJob <|-- samples.hybrid-demo.cost-computing-job.nodes.CostComputingSingularityJob
    Root <|-- samples.job.mocks.DelayJob
    SoftwareComponent <|-- nfs.pub.nodes.NFSServer
    alien.nodes.LinuxFileSystem <|-- nfs.pub.nodes.NFSClient
    nfs.pub.nodes.NFSServer <|-- nfs.linux.ansible.nodes.NFSServer
    nfs.pub.nodes.NFSClient <|-- nfs.linux.ansible.nodes.NFSClient
    SoftwareComponent <|-- ansible.pub.nodes.AnsibleRuntime
    ansible.pub.nodes.AnsibleRuntime <|-- ansible.linux.ansible.nodes.AnsibleRuntime
    org.alien4cloud.alien4cloud.config.pub.nodes.OrchestratorConfigurator <|-- yorc.alien4cloud.nodes.YorcProvider
    org.alien4cloud.alien4cloud.config.location.nodes.SimpleLocationConfigurator <|-- yorc.alien4cloud.nodes.YorcLocationConfigurator
    org.alien4cloud.alien4cloud.config.location_resources.autoconfig.nodes.ResourcesConfigurator <|-- yorc.alien4cloud.nodes.YorcAutoconfigResourcesConfigurator
    org.alien4cloud.alien4cloud.config.location_resources.on_demand.nodes.OnDemandLocationResourcesConfigurator <|-- yorc.alien4cloud.nodes.YorcOnDemandLocationResourcesConfigurator
    Root <|-- yorc.pub.location.LocationConfig
    yorc.pub.location.LocationConfig <|-- yorc.pub.location.GoogleConfig
    yorc.pub.location.LocationConfig <|-- yorc.pub.location.OpenStackConfig
    yorc.pub.location.LocationConfig <|-- yorc.pub.location.AWSConfig
    yorc.pub.location.LocationConfig <|-- yorc.pub.location.KubernetesConfig
    yorc.pub.location.LocationConfig <|-- yorc.pub.location.HostsPoolConfig
    Root <|-- yorc.pub.ansible.Config
    SoftwareComponent <|-- yorc.pub.nodes.YorcServer
    Container.Application.DockerContainer <|-- yorc.docker.nodes.Yorc
    yorc.pub.location.GoogleConfig <|-- yorc.location.GoogleConfig
    yorc.pub.location.OpenStackConfig <|-- yorc.location.OpenStackConfig
    yorc.pub.location.AWSConfig <|-- yorc.location.AWSConfig
    yorc.pub.location.KubernetesConfig <|-- yorc.location.KubernetesConfig
    yorc.pub.location.HostsPoolConfig <|-- yorc.location.HostsPoolConfig
    yorc.pub.ansible.Config <|-- yorc.ansible.Config
    yorc.pub.nodes.YorcServer <|-- yorc.linux.ansible.nodes.YorcServer
    org.alien4cloud.alien4cloud.config.pub.nodes.OrchestratorConfigurator <|-- yorc.alien4cloud.nodes.YorcPlugin
    org.alien4cloud.alien4cloud.config.location.nodes.SimpleLocationConfigurator <|-- yorc.alien4cloud.nodes.YorcLocationConfigurator
    org.alien4cloud.alien4cloud.config.location_resources.autoconfig.nodes.ResourcesConfigurator <|-- yorc.alien4cloud.nodes.YorcAutoconfigResourcesConfigurator
    org.alien4cloud.alien4cloud.config.location_resources.on_demand.nodes.OnDemandLocationResourcesConfigurator <|-- yorc.alien4cloud.nodes.YorcOnDemandLocationResourcesConfigurator
    SoftwareComponent <|-- terraform.pub.nodes.TerraformRuntime
    terraform.pub.nodes.TerraformRuntime <|-- terraform.linux.terraform.nodes.TerraformRuntime
```
#### Alien4Cloud

```mermaid
classDiagram
    Root <|-- cloudify.patches.pub.nodes.CloudifyPatch
    cloudify.patches.pub.nodes.CloudifyPatch <|-- cloudify.patches.amqp_client.nodes.AmqpClientPatch
    cloudify.patches.pub.nodes.CloudifyPatch <|-- cloudify.patches.change_max_mgmtworker.nodes.ChangeMaxMgmtWorkerPatch
    cloudify.patches.pub.nodes.CloudifyPatch <|-- cloudify.patches.change_max_fd.nodes.ChangeMaxFd
    cloudify.patches.pub.nodes.CloudifyPatch <|-- cloudify.patches.patch_mgmtworker.nodes.PatchMgmtworkTasksPy
    apache.pub.nodes.WebApplication <|-- cloudify.config.offline_plugin.nodes.PluginConfigurator
    SoftwareComponent <|-- cloudify.ansible.nodes.Ansible4CloudifyManager
    SoftwareComponent <|-- cloudify.hostpool.pub.nodes.HostPoolService
    cloudify.hostpool.pub.nodes.HostPoolService <|-- cloudify.hostpool.service.nodes.HostPool
    SoftwareComponent <|-- cloudify.hostpool.awsfeeder.nodes.AWSHostpoolFeeder
    SoftwareComponent <|-- cloudify.manager.pub.nodes.CloudifyManagerService
    Root <|-- cloudify.manager.pub.nodes.CloudifyIaaSConfiguration
    cloudify.manager.pub.nodes.CloudifyManagerService <|-- cloudify.manager.v4.nodes.CloudifyManager
    Root <|-- cloudify.manager.v4.nodes.CloudifySSHKey
    cloudify.manager.pub.nodes.CloudifyIaaSConfiguration <|-- cloudify.manager.v4.nodes.CloudifyAwsConfiguration
    cloudify.manager.pub.nodes.CloudifyIaaSConfiguration <|-- cloudify.manager.v4.nodes.CloudifyAzureConfiguration
    cloudify.manager.pub.nodes.CloudifyIaaSConfiguration <|-- cloudify.manager.v4.nodes.CloudifyOpenstackConfiguration
    cloudify.manager.pub.nodes.CloudifyManagerService <|-- cloudify.manager.v3.nodes.Cloudify3Manager
    cloudify.manager.v4.nodes.CloudifyAwsConfiguration <|-- cloudify.manager.v3.nodes.Cloudify3AwsConfiguration
    Root <|-- cloudify.manager.pub.nodes.CloudifyAsAService
    SoftwareComponent <|-- java.jdk.linux.nodes.OracleJDK
    Root <|-- java.pub.nodes.JavaSoftware
    apache.pub.nodes.Apache <|-- apache.linux_sh.Apache
    WebServer <|-- apache.pub.nodes.Apache
    WebApplication <|-- apache.pub.nodes.WebApplication
    apache.pub.nodes.Apache <|-- apache.linux_ans.nodes.Apache
    SoftwareComponent <|-- mock.pub.nodes.AbstractMock
    mock.pub.nodes.AbstractMock <|-- mock.pub.nodes.AbstractMockHost
    mock.pub.nodes.AbstractMock <|-- mock.pub.nodes.AbstractMockComponent
    mock.pub.nodes.AbstractMockHost <|-- mock.bash.nodes.BashMockHost
    mock.pub.nodes.AbstractMockComponent <|-- mock.bash.nodes.BashMockComponent
    mock.pub.nodes.AbstractMockHost <|-- mock.ansible.nodes.AnsibleMockHost
    mock.pub.nodes.AbstractMockComponent <|-- mock.ansible.nodes.AnsibleMockComponent
    SoftwareComponent <|-- monitoring.pub.nodes.MonitoringAgent
    SoftwareComponent <|-- monitoring.pub.nodes.MetricsBackend
    SoftwareComponent <|-- consul.pub.nodes.ConsulAgent
    consul.pub.nodes.ConsulAgent <|-- consul.pub.nodes.ConsulServer
    java.pub.nodes.JavaSoftware <|-- spark.linux_sh.nodes.SparkNode
    spark.linux_sh.nodes.SparkNode <|-- spark.linux_sh.nodes.SparkMaster
    spark.linux_sh.nodes.SparkNode <|-- spark.linux_sh.nodes.SparkSlave
    nodes.Job <|-- spark.jobs-linux-sh.nodes.SparkJob
    http-proxy.pub.nodes.HttpProxy <|-- squid3.linux_sh.Squid3
    monitoring.pub.nodes.MetricsBackend <|-- graphite.pub.nodes.GraphiteService
    graphite.pub.nodes.GraphiteService <|-- graphite.linux_ans.nodes.Graphite
    diamond.pub.nodes.DiamondCollector <|-- diamond.collectors.nodes.ElasticSearchCollector
    diamond.pub.nodes.DiamondCollector <|-- diamond.collectors.nodes.JolokiaCollector
    diamond.collectors.nodes.JolokiaCollector <|-- diamond.collectors.nodes.A4CCollector
    diamond.pub.nodes.DiamondCollector <|-- diamond.collectors.nodes.RabbitmqCollector
    diamond.pub.nodes.DiamondCollector <|-- diamond.collectors.nodes.PostgresqlCollector
    diamond.pub.nodes.DiamondCollector <|-- diamond.collectors.nodes.CloudifyCollector
    diamond.pub.nodes.DiamondCollector <|-- diamond.collectors.nodes.CloudifyHostpoolCollector
    monitoring.pub.nodes.MonitoringAgent <|-- diamond.pub.nodes.DiamondAgent
    Root <|-- diamond.pub.nodes.DiamondCollector
    diamond.pub.nodes.DiamondAgent <|-- diamond.agent_linux.nodes.DiamondLinuxAgent
    SoftwareComponent <|-- php.debian_sh.nodes.PHP
    Database <|-- mysql.pub.nodes.Mysql
    mysql.pub.nodes.Mysql <|-- mysql.linux_pup.nodes.Mysql
    SoftwareComponent <|-- kubernetes.kubeadm.nodes.DockerEngine
    SoftwareComponent <|-- kubernetes.kubeadm.nodes.Kube
    kubernetes.kubeadm.nodes.Kube <|-- kubernetes.kubeadm.nodes.KubeMaster
    kubernetes.kubeadm.nodes.Kube <|-- kubernetes.kubeadm.nodes.KubeNode
    SoftwareComponent <|-- aws-cli.linux_bash.nodes.AwsCli
    SoftwareComponent <|-- http-proxy.pub.nodes.HttpProxy
    elasticsearch.pub.nodes.ElasticSearchService <|-- elasticsearch.ubuntu.nodes.ElasticSearch
    java.pub.nodes.JavaSoftware <|-- elasticsearch.pub.nodes.ElasticSearchService
    elasticsearch.pub.nodes.ElasticSearchService <|-- elasticsearch.centos.nodes.ElasticSearch
    elasticsearch.pub.nodes.ElasticSearchService <|-- elasticsearch.ansible.nodes.ElasticSearch
    terraform.openstack.nodes.AbstractTerraInstance <|-- terraform.openstack.nodes.TerraInstance
    Compute <|-- terraform.openstack.nodes.AbstractTerraInstance
    Root <|-- terraform.openstack.nodes.CustomSecurityGroup
    SoftwareComponent <|-- grafana.pub.nodes.GrafanaService
    grafana.pub.nodes.GrafanaService <|-- grafana.linux_ans.nodes.Grafana
    alien4cloud.webapp.nodes.Alien4Cloud <|-- alien4cloud.demo.nodes.Alien4CloudDemo
    alien4cloud.pub.nodes.Alien4CloudService <|-- alien4cloud.webapp.nodes.Alien4Cloud
    java.pub.nodes.JavaSoftware <|-- alien4cloud.postdeployment.nodes.Postdeployment
    java.pub.nodes.JavaSoftware <|-- alien4cloud.pub.nodes.Alien4CloudService
    Root <|-- alien4cloud.pub.nodes.AlienConfigurator
    java.pub.nodes.JavaSoftware <|-- alien4cloud.tests.loadtest.nodes.JMeterTestLauncher
    alien4cloud.pub.nodes.AlienConfigurator <|-- alien4cloud.config.pub.nodes.OrchestratorConfigurator
    Root <|-- alien4cloud.config.pub.nodes.LocationConfigurator
    alien4cloud.pub.nodes.AlienConfigurator <|-- alien4cloud.config.applications.nodes.AddApplications
    alien4cloud.pub.nodes.AlienConfigurator <|-- alien4cloud.config.repository.nodes.ArtifactRepositoriesConfigurator
    alien4cloud.pub.nodes.AlienConfigurator <|-- alien4cloud.config.plugin.nodes.UploadPlugin
    alien4cloud.pub.nodes.AlienConfigurator <|-- alien4cloud.config.csar.nodes.AddCsarFromGit
    alien4cloud.pub.nodes.AlienConfigurator <|-- alien4cloud.config.repository.nodes.ArtifactRepositoriesConfigurator
    alien4cloud.config.pub.nodes.OrchestratorConfigurator <|-- alien4cloud.config.orchestrator.cfy.nodes.CfyOrchestratorConfigurator
    alien4cloud.config.orchestrator.cfy.nodes.CfyOrchestratorConfigurator <|-- alien4cloud.config.orchestrator.cfy.nodes.CfyAzureParametersConfigurator
    alien4cloud.pub.nodes.AlienConfigurator <|-- alien4cloud.config.backupRestoreS3.nodes.BackupRestoreS3
    alien4cloud.config.location.nodes.SimpleLocationConfigurator <|-- alien4cloud.config.location_resources.cfy_byon.nodes.ByonLocationResourcesConfigurator
    alien4cloud.config.location.nodes.SimpleLocationConfigurator <|-- alien4cloud.config.location_resources.on_demand.nodes.OnDemandLocationResourcesConfigurator
    alien4cloud.config.location.nodes.SimpleLocationConfigurator <|-- alien4cloud.config.location_resources.autoconfig.nodes.ResourcesConfigurator
    alien4cloud.config.pub.nodes.LocationConfigurator <|-- alien4cloud.config.location.nodes.SimpleLocationConfigurator
```
### Ubicity

Ubicity profiles define general purpose TOSCA types that aim to
implement common design patterns to handle
[abstraction](https://github.com/oasis-open/tosca-community-contributions/blob/master/profiles/com/ubicity/README.md). The
Ubicity main profile types are organized in the following node type
hiearchy:

```mermaid
classDiagram
    class Root
    Root <|-- VirtualInfrastructureTarget
    Root <|-- KeyPair
    Root <|-- Compute
    Compute <|-- VirtualCompute
    Compute <|-- PhysicalCompute
    Root <|-- Storage
    Root <|-- ComputeMonitor
    Root <|-- LinuxAccount
    Root <|-- Port
    Root <|-- Subnet
    Root <|-- Software
    Software <|-- InstallablePackage
    Root <|-- Postgres.User
    Root <|-- Postgres.Database
    InstallablePackage <|-- Postgres.DBMS
    InstallablePackage <|-- Nginx.WebServer
    Root <|-- Nginx.WebSite
    Software <|-- PipPackage
    InstallablePackage <|-- Docker
    Software <|-- Containerd
    Subnet <|-- MacVLAN
    Port <|-- MacVLANPort
    Storage <|-- DockerVolume
    Software <|-- DockerContainer
    InstallablePackage <|-- Terraform
    InstallablePackage <|-- Kubectl
    Software <|-- Helm
    Software <|-- HelmRepo
    HelmRepo <|-- LocalHelmRepo
    Software <|-- Minikube
    Software <|-- K3s
    InstallablePackage <|-- Kubernetes
    Root <|-- Cluster
```

#### Ubicity Amazon EC2
In addition, Ubicity defines various platform-specific profiles. The
following shows the profile for AWS EC2:

```mermaid
classDiagram
    Software <|-- aws.AwsCli
    Root <|-- aws.Account
    VirtualInfrastructureTarget <|-- aws.Region
    Root <|-- aws.VirtualPrivateCloud
    Subnet <|-- aws.Subnet
    Root <|-- aws.ElasticIp
    KeyPair <|-- aws.KeyPair
    Root <|-- aws.SecurityGroup
    Root <|-- aws.InternetGateway
    Root <|-- aws.RouteTable
    VirtualCompute <|-- aws.Compute
    Port <|-- aws.NetworkInterface
```

#### Ubicity Openstack
The following shows the profile for Openstack:
```mermaid
classDiagram
    PipPackage <|-- os.OpenstackCli
    VirtualInfrastructureTarget <|-- os.Region
    Root <|-- os.Account
    KeyPair <|-- os.KeyPair
    VirtualCompute <|-- os.Compute
    Port <|-- os.Port
    Root <|-- os.Network
    Subnet <|-- os.Subnet
```
#### Ubicity Proxmox
The following shows the profile for Proxmox:
```mermaid
classDiagram
    class Proxmox
    Storage <|-- vpe.Disk
    Root <|-- vpe.Image
    KeyPair <|-- vpe.KeyPair
    Compute <|-- vpe.Compute
    Software <|-- Wordpress
```

#### Ubicity Kubernetes
The following shows the profile for Kubernetes:
```mermaid
classDiagram
    Root <|-- Resource
    Resource <|-- Namespace
    Resource <|-- NamespacedResource
    NamespacedResource <|-- ServiceAccount
    Resource <|-- ClusterRole
    Resource <|-- ClusterRoleBinding
    NamespacedResource <|-- ConfigMap
    Root <|-- HelmApp
```
### Cloudify

Cloudify allows organizations to automate their existing
infrastructure alongside cloud native and distributed edge
resources. Cloudify also allows users to manage different
orchestration and automation domains as part of one common CI/CD
pipeline.

> In order the improve readability of the diagram, the leading
  `cloudify.nodes.` prefixes are omitted from the node type names.

```mermaid
classDiagram
    class Root
    Root <|-- Compute
    Compute <|-- Container
    Root <|-- Tier
    Root <|-- Volume
    Root <|-- FileSystem
    Root <|-- ObjectStorage
    Root <|-- Network
    Root <|-- Subnet
    Root <|-- Port
    Root <|-- Router
    Root <|-- LoadBalancer
    Root <|-- VirtualIP
    Root <|-- SecurityGroup
    Root <|-- SoftwareComponent
    SoftwareComponent <|-- DBMS
    Root <|-- Database
    SoftwareComponent <|-- WebServer
    SoftwareComponent <|-- ApplicationServer
    SoftwareComponent <|-- MessageBusServer
    Root <|-- ApplicationModule
    SoftwareComponent <|-- CloudifyManager
    Root <|-- Component
    Component <|-- ServiceComponent
    Root <|-- SharedResource
    Root <|-- Blueprint
    Root <|-- PasswordSecret
```
## Categorize

For the types defined in each of the contributed profiles:
- Distinguish between types that define service components
  vs. types that define the platforms on which these service
  components are deployed.
- Distinguish between abstract types and types that assume specific
  implementations.
- Distinguish between types that model the same component but use
  different implementation technologies (e.g., Ansible vs. Terraform)

### Platform Types

- IaaS (Infrastructure as a Service): You rent virtual machines and
  storage; you manage everything else.

- PaaS (Platform as a Service): You rent a ready-made platform to
  develop and deploy apps; provider manages the infrastructure.

  Examples of PaaS:

  - Heroku

  - Google App Engine

  - Microsoft Azure App Service

  - AWS Elastic Beanstalk

  - Red Hat OpenShift

- SaaS (Software as a Service): You rent and use a finished
  application (like Gmail or Salesforce).

Kubernetes is not itself a Platform as a Service (PaaS). It’s more
accurate to call it a container orchestration system or an
infrastructure platform that many PaaS offerings are built on top of.

What Kubernetes does:

- Manages containers (e.g., Docker) across clusters of machines.

- Handles scheduling, scaling, load balancing, networking, and
  self-healing of applications.

- Provides APIs and abstractions for infrastructure, but doesn’t give
  you developer-focused tools out of the box (like build pipelines,
  application runtimes, or managed databases).

Why it’s not PaaS:

- PaaS is developer-focused → You push your code, and the platform
  takes care of builds, dependencies, deployment, scaling, etc. (e.g.,
  Heroku).

- Kubernetes is infrastructure-focused → You deploy containers that
  you have already built; Kubernetes schedules and manages them.

- In fact, people often describe Kubernetes as sitting somewhere
  between IaaS and PaaS:

  - It’s more than IaaS (because it abstracts servers into a unified
    cluster).

  - It’s less than PaaS (because it doesn’t abstract away deployment
    complexity for developers by default).


PaaS existed long before Kubernetes was created (2014). For example:

- Heroku (2007) → classic PaaS, lets you git push code and deploy. No
  Kubernetes.

- Google App Engine (2008) → serverless-style PaaS, predates
  Kubernetes.

- Cloud Foundry (2011) → a PaaS with its own container/runtime system,
  not Kubernetes-based.

These platforms provided developer workflows, build pipelines, and
runtime environments without Kubernetes.

Many newer PaaS offerings do use Kubernetes under the hood, because
Kubernetes has become a de facto standard for container
orchestration. Examples:

- OpenShift (Red Hat)

- Google Cloud Run / Knative

- VMware Tanzu Application Service (K8s edition)

In these cases, Kubernetes provides a solid infrastructure layer,
while the PaaS adds developer-focused abstractions.

Some modern PaaS options still don’t depend on Kubernetes, especially
serverless PaaS:

- AWS Elastic Beanstalk (abstracts EC2, no Kubernetes required).

- AWS Lambda / Azure Functions (FaaS, sometimes called a “serverless
  PaaS”).

- Netlify, Vercel (serverless platforms for web apps, not
  Kubernetes-based).

## Harmonize

- Extract common class hierarchies

## Define Integration Points

- Define common requirement and capability definitions that model the
  integration points between node types.

## Configurations

- Define common properties and attributes that can be used to
  configure nodes and relationships and to track runtime state.

## Implementations

- Attach various implementations to the resulting node type
  definitions.