# TOSCA Community Profile Design Guide

**Related documents:** [README](../README.md) · [prior-art](prior-art.md) · [abstract-profile-proposed-changes](abstract-profile-proposed-changes.md) · [meeting-history](../../../../governance/meeting-history.md) · [decision-log](../../../../governance/decision-log.md) · [open-issues](../../../../governance/open-issues.md)

This guide describes the modeling methodology and design patterns the
TOSCA Community uses when developing community profiles: the Model
Continuum for managing abstraction, how to translate between
abstraction levels, how abstract services are deployed, and the
Component/Port pattern for modeling how nodes interact.

---

## The Model Continuum in Support of Abstraction

To manage the complexities associated with large scale systems and
services, the TOSCA Community has adopted a modeling approach that
relies heavily on the use of *abstraction*. Abstraction allows for the
creation of *high-level* models that hide *low-level* implementation
details.  To help guide the use of abstraction in service modeling, we
leverage the [*policy
continuum*](https://www.sciencedirect.com/science/article/abs/pii/S0140366408002302)
introduced by [John
Strassner](https://www.linkedin.com/in/john-strassner-41ba98a). While
the policy continuum was originally introduced to assist with the
definition of *policies* at various levels of abstraction, it can also
be used to assist with the creation of *models* to which these
policies can be applied. Therefore, this document uses the term *model
continuum* rather than *policy continuum*.

The model continuum recommends five different levels of abstraction
as shown in the following picture:

![Model Continuum](../images/model-continuum.png)

- **Business View**: describes services in terms of business goals. It
  models services as products that are available to customers.
- **System View**: describes the architectural components of the
  service in a technology-agnostic fashion. It defines the system
  architecture used to meet the business objectives specified in the
  business view.
- **Administrator View**: specifies technologies used for each of the
  architectural components in the system. It introduces
  technology-specific implementations for the architecture specified
  in the system view.
- **Device View**: lists specific devices or software
  components&mdash;as well as their associated
  configurations&mdash;for all of the components of the service. It
  introduces vendor-specific equipment for the technologies used in
  the administrator view.
- **Instance View**: captures the state of each instance and specifies
  details about the interfaces for managing these instances.

The model continuum enables a **top-down** service design approach,
where high-level designs are incrementally refined into lower levels
as follows:

1. System designers create abstract *system view* models to define the
   architecture of their systems.
2. These abstract system models are then refined using *administrator
   view* models that introduce the specific technologies chosen to
   implement the system architecture.
3. For the technologies selected in the administrator view models,
   *device view* models specify specific vendor products or software
   packages.
4. Finally, the *instance view* models add interface implementations
   based on implementation artifacts that can be used by an
   Orchestrator to manage the products specified in the device view
   models.

> **Open, not yet tracked as an issue.** Add discussion about monitoring
> and telemetry data moving in the other direction: low-level monitoring
> data are summarized and aggregated into high-level *system health*
> attributes. This is the *bottom-up* counterpart to the top-down
> refinement described above, and the mechanism already exists —
> `substitution_mappings.attributes` escalates values from a substituting
> service onto the substituted node. Needs an issue number and a written
> pattern.

As a *best practice*, TOSCA profile designers should avoid mixing and
matching types defined at different levels of abstraction within the
same profile. Instead, they should define separate profiles for system
view models, for administrator view models, for device view models,
and for instance view models, and use the techniques recommended in
this document to translate between different levels of abstraction.

The TOSCA Community provides separate TOSCA profiles for each level of
abstraction and is very clear about the level of abstraction for which
each profile is designed. The remainder of this document provides an
introduction to these profiles.

## Generic Base Node Types for System View Profiles

Top-down service design starts by defining TOSCA service templates at
the highest level of abstraction, which is the System View level in
the Model Continuum. At this level of abstraction, any service or
application generally consist of the following:

- *Application* components that provide the functionality provided by
  the service.
- Storage components that provide the persistent *data* that are
  processed by the service.
- One or more underlying *platforms* that run the application
  components that make up the service or that make persistent data
  available.
- *Networks* that connect various platforms.

To assist with the development of abstract service templates, the
TOSCA Community profiles include a System View profile that defines
base node types for these four *generic* abstractions. Specifically,
it defines:

- An `Application` node type that represents the functionality
  provided by the service.
- A `Data` node type that represents the persistent data processed by
  the service. This data node type can model Data Sets, Data Lakes,
  Databases or similar entities.
- A `Platform` node type that represents the platforms on which the
  service components are deployed.
- A `Network` node type that represents connectivity between
  platforms.

These node types&mdash;as well as the supporting relationship types
and capability types&mdash;are organized in the
`community.tosca.abstract.base` profile. It can be used to guide the
development of abstract service templates as shown in the following
figure:

![Generic System View Service Template](../images/generic-template.png)

## Component-Specific System View Profiles

In practice, abstract service templates generally will not use the
*generic* base node types presented in the `community.tosca.abstract.base`
profile. Instead, they will use derived types that further refine and
extend these base types. For example, derived `Data` node types could
distinguish between databases and data lakes, or derived `Platform`
node types could specify whether applications are deployed on
Kubernetes clusters or on servers provisioned on IaaS platforms, etc.

To this end, the TOSCA Community defines four additional System View
profiles as shown in the following figure:

![System View Profiles](../images/system-view-profiles.png)

Each of these profiles defines derived node types for one of the four
base node types defined in the base profile. These profiles can then
be used to define abstract TOSCA service templates that define specific
applications or services. The following figure shows an example of
such an abstract service template:

![Abstract Service Template](../images/abstract-template.png)

## Translating Between Levels of Abstraction

During the orchestration process, TOSCA service templates that use
types defined a higher level of abstraction must be extended with
information that is specific to the next lower level of
abstraction. The TOSCA language provides two mechanisms to accomplish
this:

### Derivation

Using the derivation approach, base node types define abstract
entities. Derived types provide concrete implementations for those
abstract definitions. This approach is shown in the following figure:

![Derivation](../images/derivation.png)

### Substitution

Using the substitution approach, base node types define an abstract
interface, a *facade* if you will. Substituting templates provide
concrete implementations for the abstract facade. This approach is
shown in the following figure:

![Substitution](../images/substitution.png)

### Passing Implementation Details Across a Substitution Boundary

Abstract node types *hide* the details required at lower levels. That is what
makes them abstract, but it creates a problem during substitution: the
substituting template frequently needs some of what was hidden. A mechanism is
therefore needed to supply those lower-level details without burdening the
abstract node types with information that means nothing at their level.

**This is a recommended practice, not a requirement of the specification.**
§15.2 requires property mappings only for non-optional service template inputs
that do not define a `default` value, so a substituting template is free to
declare additional inputs that are never mapped at all, provided they are
optional or carry a default. Nothing here overrides that.

**What the recommendation is for.** An unmapped input with a default can only
carry a value fixed when the substituting template was authored, which makes it
a lowest-common-denominator value across every use of that template. It can
never carry a value that differs per substituted node. Where a value does vary
with the node being substituted, mapping is the only mechanism that crosses the
substitution boundary. The two are therefore not competing solutions to one
problem:

- **An unmapped input with a default** suits a value that is genuinely constant
  across every use of the realization.
- **A mapped property** is required as soon as the value depends on which node
  is being substituted.

The pattern below is how the community profiles carry a *set* of such
per-node values without declaring each one on the abstract type. It uses an
*opaque* `implementation-details` property, passed to the substituting template
and parsed only in that template's context.

1. All abstract nodes define a property called `implementation-details` that
   contains a structured set of lower-level details that can simply be ignored
   at the highest level of abstraction. The value of this property can be
   encoded in a variety of ways&mdash;including YAML, JSON, or some other
   mechanism&mdash;but the community profiles use YAML encoding. The [core
   profile](../core) defines a `YAML` data type for this purpose. The abstract
   node should validate that the provided string is well-formed YAML, but it
   does not need to know about the specific values carried in that string. This
   allows arbitrary implementation detail data to be provided in the abstract
   node.

   YAML is used rather than JSON because the surrounding service template is
   itself a YAML document. JSON is a subset of YAML, so nothing is given up,
   while the value can be written as a block scalar instead of a quoted
   string&mdash;which permits line breaks and comments, and avoids quoting a
   JSON document inside YAML:
   ```yaml
   node_templates:
     my_app:
       type: base:Application
       properties:
         implementation-details: |
           service_label: frontend
           # the deployment label is optional
           deployment_label: web
   ```
   When authoring a block scalar, the whole block must share a common base
   indentation: the base is taken from the first non-empty line, every line
   must be indented at least that far, and any extra indentation is preserved
   as structure. Tabs are not valid YAML indentation and must not appear in the
   encoded value.
2. In the substituting template, we define a substitution mapping that maps the
   `implementation-details` property value to an input of the substituting
   template. For example, the following shows how the `implementation-details`
   property is mapped to a service template input called `yaml_data` which is
   also of type `YAML`:
   ```yaml
   service_template:
     substitution_mappings:
       node_type: app:MicroService
       properties:
         implementation-details: yaml_data
     inputs:
       yaml_data:
         type: YAML
   ```
3. The substituting template then defines another service template input that
   uses a TOSCA data type to represent the implementation details. For example,
   the following shows a TOSCA data type called `ImplementationDetails` and an
   input value of that type called `implementation-details`. Note that
   substituting templates are free to choose different data type names and
   different input names:
   ```yaml
   data_types:
     ImplementationDetails:
       properties:
         service_label:
           type: string
         deployment_label:
           type: string
         security_context:
           type: k8s:SecurityContext
   service_template:
     inputs:
       yaml_data:
         type: YAML
       implementation-details:
         type: ImplementationDetails
   ```
4. Finally, the key to making this work is to fix the value of the
   `implementation-details` input to the data that are returned by decoding the
   YAML string in the `yaml_data` input, as follows:
   ```yaml
   service_template:
     substitution_mappings:
       node_type: app:MicroService
       properties:
         implementation-details: yaml_data
     inputs:
       yaml_data:
         type: YAML
       implementation-details:
         type: ImplementationDetails
         value: {$decode_yaml: [{$get_input: yaml_data}]}
   ```
   Note that this requires a custom `$decode_yaml` function.
5. The TOSCA processor will then validate the data returned by the
   `$decode_yaml` function against the `ImplementationDetails` data type,
   thereby ensuring (at deployment time) that correct implementation details
   have been provided in the abstract node.

   This step is what makes the opaque property safe: the value is untyped only
   while it crosses a boundary that could not have typed it, and the decode
   step is where the substituting template&mdash;which does know the
   schema&mdash;re-establishes typing.
6. In the substituting template, whenever one of the implementation detail
   values are required, they could be retrieved using `$get_input` function
   calls, for example as follows:
   ```yaml
   $get_input: [implementation-details, service_label]
   ```

### Translation Best Practices

#### Translating System View to Administrator View

We recommend using *substitution mapping* to translate from the system
view level of abstraction to the administrator view level of
abstraction, as shown in the following figure:

![Translate system view to administrator view](../images/system-to-administrator.png)

Note that this recommendation does not prohibit the use of
*inheritance* to further refine types defined in *system view*
profiles. In fact, inheritance could be useful to define base node
types that define common functionality (e.g. interfaces) that is then
shared by all node types derived from that base type. However,
inheritance should not be used to add technology-specific or
vendor-specific implementations to system view node types.

#### Translating Administrator View to Device View
We recommend using *derivation* to map from the administrator view
level of abstraction to the device view level of abstraction, as shown
in the following figure:

![Translate administrator view to device view](../images/administrator-to-device.png)

#### Translating Device View to Instance View

Derivation could be used again to translate from the device view level
of abstraction to the instance view level of abstraction, as shown in
the following figure.

![Translate device view to instance view](../images/device-to-instance.png)

This figure suggests that different derived classes could add
different types of artifacts that can be used as interface operation
implementations. One derived node type could use Ansible playbooks, a
second derived node type could use Terraform configurations, and a
third could use simple Bash scripts.

However, this approach could result in a proliferation of profiles. A
better approach would be to *dynamically* attach implementations to
the types defined in device view profiles without having to introduce
new derived types. Unfortunately, the TOSCA language currently does
not have any constructs to support such dynamic behavior.

> **Tracked as issue I14** (dynamic attachment of implementation
> artifacts). Needs a language construct; open against a future spec
> version.

### Mapping Relationship Types and Capability Types

> It is likely that the same guidelines about abstraction apply to
  relationship types as well. However, the TOSCA spec is somewhat
  vague about whether requirement mappings rules (and capability
  mapping rules for that matter) require that the relationships
  resulting from the mapping have types that are compatible with the
  relationship of the mapped requirement. If that is the case, then
  these relationship types (and capability types) must be shared
  between System View, Administrator View, and Device View profiles
  and may need to be organized in a *shared* profile.  This shared
  profile should only define top-level relationship types or
  capability types. Profile-specific types should derive from one of
  the base types defined in the base profile.

  > **Tracked as issue I15**, and related to I1 (single source of truth
  > for shared types). If the mapping rules do require type
  > compatibility, the shared top-level relationship and capability
  > types belong in `community.tosca.core` — which already owns the
  > three base relationship/capability kinds — so that System View,
  > Administrator View, and Device View profiles all derive from a
  > single source.

### Profile Organization

The approach recommended in this section has resulted in a set of
profiles as shown in the following figure:

![TOSCA Community Profiles Organization](../images/profile-organization.png)

The profiles on the right are *Administrator View* and *Device View*
profiles, where *Device View* node types derive from node types
defined in *Administrator View* profiles. One such Administrator View
profile is the IaaS profile that defines node types that represent
entities managed by Infrastructure-as-a-Service platforms. These types
are then refined in profiles specific to each IaaS provider, such as
AWS, Azure, etc.

The *Core* profile defines types, repositories, functions, etc. that
are shared by profiles at different levels of abstraction.

> The *naming* convention for these profiles — the `community.tosca.*`
> namespace versus reverse-DNS names such as `io.kubernetes` — is an open
> question tracked as issue I22 and written up in
> [profile-naming.md](profile-naming.md).

### Two Dimensions Determine Where a Type Belongs

The level of abstraction is not the only thing that decides which
profile a node type belongs in. Profile organization is governed by two
*independent* dimensions, and a type must be located in both before a
home can be chosen for it.

Both dimensions are already present in the figure above. The first is
the *model continuum*, which runs vertically: the figure labels System
View profiles *technology and vendor independent*, Administrator View
profiles *technology specific*, and Device View profiles *vendor
specific*. The second runs horizontally, and appears in the figure as
the decomposition of the System View level into separate Platform,
Application, Data, and Network profiles. The section on [decoupling
applications and data from platforms](#decouple-applications-and-data-from-platforms)
below applies that same separation to the design of abstract service
templates.

What the figure does not yet show is the two dimensions *crossed below
the System View level*. Its Administrator View row contains IaaS,
Kubernetes, and Docker profiles, and its Device View row contains AWS,
OpenStack, and Proxmox profiles — all of them platform profiles. The
application, data, and network columns have no Administrator View or
Device View counterparts in the figure, yet the reasoning that
justifies them at the System View level applies unchanged further down:
a certificate authority is a technology-specific concept in the same
way a Kubernetes cluster is, and a particular certificate authority
implementation is vendor-specific in the same way AWS is.

Taken together, the two dimensions therefore produce four categories
rather than one column of three:

|                        | **Platform**                                              | **Application**                        |
| ---------------------- | --------------------------------------------------------- | -------------------------------------- |
| **Administrator View** | a Kubernetes cluster; a container runtime; an OCI registry | a certificate authority; an image registry |
| **Device View**        | k3s, k0s, minikube, kubeadm; containerd, Docker Engine     | step-ca; zot; Harbor                   |

A type that appears to belong in two of these categories at once is not
a single type. A node type *named* for a technology-neutral role while
its properties describe one specific product spans the Administrator
and Device rows simultaneously, and no profile can hold it correctly.
The remedy is to rename the type for the product it actually models, or
to separate it into two types, rather than to select a compromise
profile for it.

In practice the Administrator View cell of the application column is
frequently filled by a *capability type* rather than by a node type.
Where consumers bind a port rather than a node — see the [Component/Port
Pattern](#componentport-pattern) below — the technology-neutral concept
is already expressed by the capability that the port advertises, and the
node type only ever needs to be the Device View realization, named for
its product.

This is what makes an intermediate abstract node type unnecessary, and
the alternative is not merely redundant but unbuildable. Suppose the
technology-neutral concept were modeled as a node type at the
Administrator View row. A Device View product type would then reach it
by *derivation*, following the recommendation in [Translating
Administrator View to Device
View](#translating-administrator-view-to-device-view) above. But that
same product type must also derive from the type that represents how it
is realized. That is one `derived_from` and two required parents, and
TOSCA node types are singly inherited. Expressing the neutral concept as
a capability avoids the contradiction entirely, because a port is
*bound* rather than *inherited*, and binding carries no such limit.

This is a specific instance of a more general tension already noted in
[Translating Device View to Instance
View](#translating-device-view-to-instance-view) above: where derivation
is the only mechanism available for crossing a boundary, every
independent axis of variation has to be expressed as another derived
type. Capabilities relieve that pressure wherever what the consumer
needs is a contract rather than an ancestor.

> The profile organization figure above depicts the horizontal dimension
> only at the System View level. Extending it to show application (and
> data, and network) profiles at the Administrator View and Device View
> levels would make the four categories described here visible in the
> figure itself.

## Deploying Abstract Services

This section describes the process that could be implemented by TOSCA
processors for deploying abstract services. This process recommends
the following steps:

1. Decouple applications and data from platforms.
2. Make placement decisions based on available platforms.
3. Placement decisions drive substitution.
4. Resolve the placement edge through the substitution, recursively where
   the allocated platform is itself abstract.

### Decouple Applications and Data from Platforms

High-level service designs should be *abstract and portable*, which
means they should be independent of the target platform on which these
services will ultimately be deployed. With this goal in mind, abstract
TOSCA service templates should focus on application topology only and
must not include node templates for the platforms on which the
services are deployed. Instead, node templates for applications and
data in abstract service templates should include requirements for
capabilities in the target platform(s) on which the service can be
deployed.

The following shows a hypothetical example of such an abstract service
template that defines a simple web application that operates on data
stored in a relational database:

![Technology Independent Service Design](../images/service-design.png)

In this example, the `host` requirements of the application and data
node templates are left *dangling*. These requirements need to be
fulfilled by the TOSCA Processor at service deployment time.

To fulfill these dangling requirements, TOSCA processors should
maintain representations of the available platforms on which services
can be deployed. These representations should contain sufficient
information to allow TOSCA processors to make intelligent placement
decisions. For example, platform representations could include the
following:

  - Location: where is the platform physically located?
  - Capabilities: what type of platform is it and what types of
    workloads can the platform support?
  - Capacity: how much load can be placed on the platform?
  - Access: how to access the platform?

The following shows a representation of the platforms available for a
specific customer. 

![Available Platforms](../images/platforms.png)

### Make Placement Decisions

When deploying an abstract service, the TOSCA Processor first makes
placement decisions by *fulfilling* the dangling `host` requirements of
the nodes in the abstract service representation using capabilities of
the nodes in the abstract platform representations. Node filters can
be used to narrow down the set of candidate target platforms. The
following figure shows a node filter that drives placement for the
`application` node in the abstract service template.

![Placement Decisions](../images/placement.png)

The capability named by the requirement determines which platforms are
*eligible*; the node filter then chooses among them. In practice a
placement filter usually compares **properties** of the candidate — its
location, its capacity, what it is designated to be — rather than
matching further capability types, because eligibility has already been
settled by the capability. In the abstract service template this looks
as follows:

```yaml
node_templates:
  application:
    type: <abstract application node type>
    properties:
      <where this application may run>: [...]
    requirements:
      # Left dangling: no target node is named. The processor fulfils it
      # at deployment time against the available platform representations.
      - host:
          node_filter:
            $has_entry:
              - {$get_property: [SELF, SOURCE, <where this application may run>]}
              - {$get_property: [SELF, TARGET, <where this platform is>]}
```

**A node filter may be declared in two places, and both are applied.** A
requirement *definition* in a node type may carry a `node_filter`, and a
requirement *assignment* in a template may carry another. A processor
evaluates both, so a template can narrow the placement its type permits
but can never relax it. Profile designers should treat a filter written
into a type as permanent for every consumer of that type, and prefer to
leave placement policy to the templates unless the constraint is truly
intrinsic to the type.

#### Filters and Missing Values

Platform representations are rarely populated uniformly — one platform
may publish its capacity while another does not — so filters must
tolerate absent values. TOSCA's comparison functions are *three-valued*
for this reason: an operand that has no value evaluates to null, a
comparison with a null operand returns null rather than false, and `$and`
skips null operands rather than failing on them.

The practical effect is that a filter listing several constraints
degrades gracefully: it constrains on exactly the fields both sides
populate, and the remaining constraints begin to apply, with no change to
the filter, as platform representations grow richer. This is what makes
it safe to write a thorough placement filter against representations that
are only partly filled in.

**Note the asymmetry between the two kinds of filter**, which is easy to
be caught by:

| | Filter evaluates to null |
|---|---|
| **Node filter** (placement) | the candidate **passes** — the constraint is skipped |
| **Substitution filter** (realization) | the template **does not match** |

Placement is permissive about what it does not know; realization
selection is not. A substituting template whose filter reads a property
the abstract node does not populate will simply never be selected.

### Placement Drives Substitution

Once placement decisions have been made, the TOSCA Processor finds
substituting templates that are suitable for the allocated target
platform. This is done by feeding information about that target
platform into the *substitution filters* of the candidate substituting
templates.

Because placement has already been made, the filter can reach the
allocated platform through the requirement that was just fulfilled. A
substitution filter is evaluated against the node being substituted, so
it uses a TOSCA Path that traverses that relationship to its target:

```yaml
substitution_mappings:
  node_type: <abstract application node type>
  substitution_filter:
    $equal:
      - {$get_property: [SELF, RELATIONSHIP, host, 0, TARGET, <property naming the platform>]}
      - <the value this substituting template claims>
```

This is what keeps the abstract service template free of technology. The
template says only what the application needs and where it may run, and
the *realization* asks what it was placed on. No property has to be added
to the application to record which technology should deploy it: that
choice belongs to the platform, and the application reaches it across the
`host` requirement.

**Do we need a function that returns a node type?** Filtering on a
*property* of the allocated platform is sufficient, and is preferable to
filtering on its type:

- Platforms of **different types** — a Kubernetes cluster versus a Docker
  engine, as in the examples below — can be distinguished either way,
  since a type that is distinct can also expose a property saying what it
  is.
- Platforms of the **same type** cannot be distinguished by type at all.
  This case is common: a fleet of like devices differing only in what each
  is designated to become is one node type carrying different property
  values, and a type-returning function would find them identical.

A property filter covers both cases and a type filter covers only one,
which argues against introducing the function. It does place a
requirement on the platform representation: it must carry a property that
*distinguishes* the platform, which the [platform representation
list](#decouple-applications-and-data-from-platforms) above does not yet
call out. Location, capabilities, capacity and access describe what a
platform *is and can do*; selecting a realization additionally needs to
know what it is *designated to be*.

> **Proposed resolution for issue I13** (`type-of-node` / "hash type"
> function). Recommends *not* adding the function, on the grounds that
> property-based selection is strictly more general. Consistent with the
> direction already recorded for I4 (abstract-types vs. minimal-types),
> which leans toward property-based substitution.

**Filters must be mutually exclusive.** A processor selects the *first*
candidate whose substitution filter matches, and raises an error when
none does. Neither outcome is negotiable by the template author, so the
author of a set of substituting templates for the same abstract node type
is responsible for ensuring that at most one filter can match any given
node. Selecting on the allocated platform makes this straightforward:
each realization claims a different platform designation, so exclusivity
follows from the filters rather than having to be maintained separately.

**The allocated platform may itself be abstract.** A platform
representation can be a node that is substituted in turn, in which case
the `host` requirement of the substituting service's inner node cannot be
resolved against it directly. The processor resolves this recursively: it
maps the requirement onto the substituted node's relationship, and where
that target is itself abstract, drills into *that* node's substituting
service, reads its `substitution_mappings.capabilities` for the named
capability, and recurses on the inner node the mapping names. The edge
therefore crosses both substitution boundaries and resolves against the concrete
node. Nothing extra need be declared for this beyond the two mappings each
side already provides: a capability mapping on the platform side, and a
requirement mapping on the application side.

#### Substitute for Kubernetes

The following figure shows an example where the application node in
the abstract service is deployed on a Kubernetes cluster.

![Placement on Kubernetes](../images/placement-k8s.png)

This information is then used to substitute the abstract application
node with substituting templates that implement this node by deploying
Kubernetes resources. TOSCA type definitions from the TOSCA Kubernetes
Profile are used for the templates in the substituting service:

![Substitution for Kubernetes](../images/substitution-k8s.png)

#### Substitute for Docker

The following figure shows an alternative deployment on a Docker
engine:

![Placement on Docker Engine](../images/placement-docker.png)

In this scenario, the abstract application node is substituted using
templates that implement this node by deploying the application
directly using Docker. TOSCA type definitions from the TOSCA Docker
Profile are used for the templates in the substituting service:

![Substitution for Docker](../images/substitution-docker.png)


---

## Component/Port Pattern

TOSCA uses a **Component/Port** pattern where a component’s touch
points for interacting with other components are modeled separately
from that component using *port* abstractions. Using TOSCA, components
are modeled using *Node Types* and the ports of those components are
modeled using the following two different abstractions associated with
node types:
- Capabilities: for functionality exposed by a component and usable by
  other components.
- Requirements: for dependencies of one component on functionality
  exposed by other components.

**Naming principle.** Capability type names should describe the
*functionality a component exposes*; relationship type names should
describe the *semantics of the dependency* — the intent of the source
node toward the target — and not the mechanism used to realize it.
Intent-revealing names (`Monitors`, `ManagedBy`, `RegistersWith`,
`HostedOn`) are preferred over mechanism-flavored names (`ConnectsTo`,
`BindsTo`, `LinksTo`). This keeps service templates readable: the reader
should understand *why* two nodes are related from the type name alone.

**Data placement.** A port is not only the structural touch point between
two components; it is where a component's *exposed contract* lives. The
properties and attributes a *consumer* reads across a binding — the
coordinates it needs to use the exposed functionality — belong on the
**capability**, not on the node. State that is internal to how the
component is realized or deployed stays on the node.

Decide by asking: *does a bound consumer read this value?* If a node bound
through a requirement reads it (through the capability), it is part of the
exposed contract and belongs on the capability; if only the component's own
operations use it, it is realization detail and stays on the node.

This is what lets the Component/Port pattern support substitution. A
consumer that reads the contract from the capability (using the TOSCA Path
`CAPABILITY` step, e.g. `[SELF, RELATIONSHIP, <requirement>, CAPABILITY,
<attribute>]`) depends on the *capability type*, not on the node type behind
it. Any node that advertises the capability — a different realization, or a
substituting service template — then satisfies the consumer unchanged. Put
the contract on the port and the implementation behind it becomes swappable;
leave it on the node and every consumer is coupled to that node type.

For example, a certificate authority exposes its issuing endpoint, trust
root, and enrolment credential on a *certification* capability rather than
on the (deployment-specific) CA node, so an enrolling node works against any
CA realization; an OCI registry exposes its endpoint, scheme, TLS trust
anchor, and deposit credential on its *registry* capability, so a publisher
pushes without knowing whether the registry is zot, Harbor, or a hosted
service.

When a base capability has several realizations, a second question follows:
*which* capability carries a given value? Decide by whether it is universal or
realization-specific. A contract **every** realization exposes belongs on the
**base capability**; a value **specific to one** realization belongs on a
**capability derived from** that base — so realizations differ without the base
accumulating every realization's fields. This is the same derive-to-specialize
discipline the pattern applies to type *naming*, now applied to the contract's
*data*: enrich the base for what is common, derive a capability for what is not.

**Secrets are references, not values.** Related to data placement, but
broader: a component's model — its properties and attributes, and the inputs
and outputs that flow through them — must carry *references* to secret
material, never the material itself. A password, token, or private key belongs
in a vault or a mounted file on the executing host; the model carries only a
**path or name** the runtime resolves there. A secret placed in a property, an
attribute, or an inputs file leaks: inputs are often committed to source
control, and attributes surface in deployed-model state where any consumer can
read them back. Where a secret's *value* originates is a separate choice — an
operator may supply it out of band (a reference to an existing vault entry),
or, when the orchestrator controls both ends of a channel, an operation may
generate it directly into a vault and hand back only the path. Either way the
model sees a reference; the value never becomes a modeled value.

The Component/Port pattern defines *common* categories of
functionality that are typically exposed by all components. It then
attempts to define *common* capability types and *common* relationship
types to represent each of these categories of functionality. Note
that this pattern is inspired by the [ONF Core Information
Model](https://opennetworking.org/software-defined-standards/models-apis/),
the [TMF Open Digital Architecture](https://www.tmforum.org/oda/), and
other modeling efforts that use a similar approach. These standard
categories of functionality are shown in the following picture:

![Component/Port Pattern](../images/component-port.png?raw=true)

- **Runtime environment**: most if not all TOSCA nodes are contained
  by (*hosted on*) another node and their lifecycle is determined by
  the lifecycle of the containing node. This containment dependency is
  expressed using an *execution environment requirement* that must be
  fulfilled by a corresponding *execution environment capability* of
  the containing node. Nodes that can *host* other nodes typically
  have their own *runtime environment requirement*.
- **Core functionality**: the main function of a TOSCA node is to
  provide a specific set of features or functionality to other
  nodes. This is expressed using a *core functionality capability*.
  Other nodes will define requirements for this functionality.
- **Management**: many TOSCA nodes are matched with a corresponding
  management tool. This relationship is expressed as a *management
  requirement* of the managed TOSCA node rather than as a *management
  capability* to express potential deployment dependencies: if the
  management tool is used to configure the TOSCA node, the management
  tool must be deployed before the managed node can be fully deployed.
  Note that for management tools, the management functions are exposed
  as their *core functionality capability*. Because management is
  modeled as a requirement of the managed node, a *reverse* "manages"
  capability/relationship on the management tool is **not** needed and
  should be avoided — it duplicates the same dependency in the opposite
  direction.
- **Monitoring**: many TOSCA nodes are matched with a corresponding
  monitoring tool. The monitored node exposes an *observability
  capability*; the monitoring tool declares a *monitoring requirement*
  that targets it. This is a *dependency* relationship (the monitored
  node must be deployed and observable before monitoring can attach),
  so the monitoring relationship derives from `DependsOn`. Modeling
  observability as a capability of the *monitored* node — rather than as
  a capability of the monitoring tool — keeps the direction consistent
  with management: the touch point lives on the node being acted upon.

  > **Proposed resolution for issue I17.** Formalizes the monitoring
  > pattern that was discussed in the TOSCA TC but never written down.

- **Security**: securing access to a node is not one concern but
  several, each modeled with its own capability/relationship pair. Note in
  particular that *authentication* (proving **who** a consumer is) and
  *authorization* (**what** that consumer may do) are distinct concerns and
  should not be conflated, even though a bearer credential often fuses them:
  - *Perimeter protection* — a node exposes a capability indicating it
    can be fronted by a security control (firewall, gateway); the
    protected node declares a requirement targeting it. (A coarse,
    network-layer authorization boundary.)
  - *Authentication / credentials* — a node exposes a capability
    representing the credential(s) by which a consumer **proves its
    identity** to access it; the consumer declares a requirement that it
    is authenticated using that credential. This establishes *who* the
    consumer is, not *what* it may do.
  - *Authorization* — what an authenticated principal is **permitted to
    do**. A credential proves identity; authorization is the policy
    applied to that identity. Today this is usually *coarse* — holding a
    bearer credential grants access, and perimeter controls gate at the
    network layer — so it rides on the credential and perimeter patterns.
    *Fine-grained* authorization (roles / scoped permissions modeled as
    their own capabilities and requirements, so that "identity X may do A
    but not B" is expressible) is a further, less-developed sub-pattern.
  - *Identity / registration / trust* — a node (a registry or trust
    store) exposes a registration capability; devices and services
    declare a *registration requirement* (e.g. `RegistersWith`) so that
    their signed requests can later be verified by relying parties.

  > **Proposed resolution for issue I17.** Replaces "this pattern needs
  > further work" by splitting security into perimeter, authentication,
  > authorization, and identity/trust sub-patterns — keeping authentication
  > and authorization distinct rather than fused under "credentials."

**The category list is open-ended.** The categories above are the
*common* ones, not an exhaustive set. Other recurring cross-cutting
categories follow the same pattern and may warrant their own common
capability and relationship types — for example *provisioning* (a node
built from an image or package source), *networking* (attachment to
hosts and networks), and *routing* (directing traffic to a target). New
categories should be introduced deliberately, documented here, and given
capability and relationship types that follow the naming principle
above.

As stated earlier, the TOSCA Community uses this pattern to define common
capability types and common relationship types for these various
categories of functionality. These types are discussed next.

### Best Practices

> **Proposed resolutions for issue I16.** The three questions below were
> previously open; the recommendations are proposed for community
> ratification. Related to I4 (abstract-vs-minimal types).

**1. Where should the capability↔relationship constraint be declared —
`valid_capability_types`, `valid_relationship_types`, or both?**

Declare it in **one** place, not both. The recommended convention:

- Put `valid_relationship_types` **only on the three base capability
  types** (`Container`, `Feature`, `Partner`), where it enforces the
  containment / dependency / association *kind* gate.
- Put `valid_capability_types` **on relationship types** to point each
  relationship at the specific capability it targets.

Restating both on every derived type is redundant, and — under TOSCA's
nominal typing — invites the two lists to drift out of sync.

**2. When should a new derived relationship or capability type be
defined, versus reusing a base type?**

Derive a new type when at least one of these holds:

1. A **semantically clearer name** improves the readability of profiles
   and templates (the name reveals intent that the base type does not).
2. **Additional properties or attributes** are needed on the
   relationship or capability.
3. **Additional inputs or operation implementations** are needed on a
   relationship interface.
4. **Additional interfaces** are needed on the relationship.

If none of these apply — the type would differ only in which nodes it
connects — do **not** derive a new type.

**3. If a specific capability and a specific relationship to it are
needed, derive new types or specialize the base types in place?**

Follow from question 2: if a case in (1)–(4) applies, derive the types.
Otherwise, reuse the base types and constrain them at the point of use
with `valid_source_node_types` / `valid_target_node_types` in the
capability and requirement definitions. This keeps the type hierarchies
shallow and avoids a proliferation of near-identical types.
