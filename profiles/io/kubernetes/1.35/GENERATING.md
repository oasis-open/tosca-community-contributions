# Generating and Post-Processing the Kubernetes Profile

**Status:** Working procedure.
**Scope:** How `io.kubernetes:1.35` is generated from the upstream Kubernetes
OpenAPI specification with `oas2tosca --kubernetes` from
[any2tosca](https://github.com/ubicity-corp/any2tosca), and the manual post-processing that turns the generated
types into a working TOSCA 2.0 profile.

The Kubernetes profile is **not written by hand**. It is generated from the
Kubernetes OpenAPI specification and then post-processed. This document records
both halves so the profile can be regenerated and re-finished reproducibly.

## Design principles

TOSCA node types mirror the structure of a Kubernetes manifest:

```yaml
apiVersion: <api-group/version>
kind: <ResourceKind>
metadata:
  name: <resource-name>
  namespace: <optional-namespace>
  labels: { key: value }
  annotations: { key: value }
spec:
  # resource-specific configuration
```

Accordingly, every TOSCA Kubernetes node type:

- defines a `metadata` property, and
- defines a resource-specific `spec` property whose data type is specific to the
  resource kind.

Because each manifest field — down to the resource-specific `spec` — is modeled
as a typed TOSCA data type mirroring the Kubernetes schema, a TOSCA processor can
**validate resource definitions at design time**, catching malformed or
out-of-range values before they are applied to a cluster.

---

## Part 1 — Generation (automatic)

### 1. Download the Kubernetes OpenAPI specification

Resolve the latest stable Kubernetes minor-release branch and download its
OpenAPI (v2 / swagger) spec:

```bash
# stable.txt returns the latest stable patch (e.g. v1.35.2); derive the
# matching release-<major>.<minor> branch (e.g. release-1.35).
BRANCH=$(curl -sL https://dl.k8s.io/release/stable.txt | sed -E 's/^v([0-9]+\.[0-9]+).*/release-\1/')
curl -o k8s-openapi-v2.json \
  "https://raw.githubusercontent.com/kubernetes/kubernetes/$BRANCH/api/openapi-spec/swagger.json"
```

To pin a specific Kubernetes version instead, set `BRANCH` explicitly
(`BRANCH=release-1.35` for this profile).

### 2. Convert to TOSCA with `oas2tosca --kubernetes`

`oas2tosca` is part of [any2tosca](https://github.com/ubicity-corp/any2tosca) (`pip install "any2tosca>=0.2"`).
With `--kubernetes` it writes one TOSCA 2.0 file per API group, packaged as one
profile:

```bash
oas2tosca --kubernetes k8s-openapi-v2.json --profile io.kubernetes:1.35 -o k8s-generated
```

What the generated files contain:

- **Files.** One per GA API group (`core.yaml`, `apps.yaml`, `batch.yaml`, …; the
  `resource.k8s.io` group is `dra.yaml`), plus `meta.yaml`, `resource.yaml`
  (`Quantity`), `runtime.yaml` and `intstr.yaml` for the apimachinery packages the
  groups share, and `apiextensions.yaml` and `apiregistration.yaml`. Alpha and beta
  versions and the `*List` kinds are left out; for `autoscaling`, `v2` replaces
  the `v1` `HorizontalPodAutoscaler`. `profile.yaml` imports every file in
  dependency order, and `TOSCA.meta` names it as the entry definitions.
- **Node types** for the resources: the schemas the API creates in a collection
  it can also read back. Action requests (`Binding`, `Eviction`, `TokenRequest`,
  the access reviews) and `Scale` are data types. No node type derives from
  another.
- **Resource metadata.** Each resource node type carries its
  `x-kubernetes-group-version-kind` as metadata (`group: ''` for the core group),
  has no `apiVersion` or `kind` property (the type determines both), and declares
  `status` as an attribute.
- **Merge semantics** of lists and maps (`x-kubernetes-list-type`,
  `x-kubernetes-list-map-keys`, `x-kubernetes-map-type`) as property metadata.
- **Embedded resources.** A resource used as a value inside another schema has a
  companion data type with the same properties: `StatefulSetSpec.volumeClaimTemplates`
  is a list of `core:PersistentVolumeClaimValue`.
- **Untyped values.** TOSCA has no `any` type, so a schema that accepts any JSON
  value derives from `string`, as does `IntOrString`.
- **Validation** where the schema states bounds (`minimum`, `maximum`,
  `pattern`, `enum`). Integer formats (`int32`, `int64`) add no range check.

### 3. Copy the generated files into the profile

Copy the generated files, except `profile.yaml` and `TOSCA.meta`, into
`io/kubernetes/1.35/`, and set the `imports` list of the profile's `profile.yaml`
to the generated one.

Generated node types, by file:

**admissionregistration.yaml:** `MutatingWebhookConfiguration`,
`ValidatingAdmissionPolicy`, `ValidatingAdmissionPolicyBinding`,
`ValidatingWebhookConfiguration`

**apiextensions.yaml:** `CustomResourceDefinition`

**apiregistration.yaml:** `APIService`

**apps.yaml:** `ControllerRevision`, `DaemonSet`, `Deployment`, `ReplicaSet`,
`StatefulSet`

**autoscaling.yaml:** `HorizontalPodAutoscaler`

**batch.yaml:** `CronJob`, `Job`

**certificates.yaml:** `CertificateSigningRequest`

**coordination.yaml:** `Lease`

**core.yaml:** `ConfigMap`, `Endpoints`, `Event`, `LimitRange`, `Namespace`,
`Node`, `PersistentVolume`, `PersistentVolumeClaim`, `Pod`, `PodTemplate`,
`ReplicationController`, `ResourceQuota`, `Secret`, `Service`, `ServiceAccount`

**discovery.yaml:** `EndpointSlice`

**dra.yaml:** `DeviceClass`, `ResourceClaim`, `ResourceClaimTemplate`,
`ResourceSlice`

**events.yaml:** `Event`

**flowcontrol.yaml:** `FlowSchema`, `PriorityLevelConfiguration`

**networking.yaml:** `IPAddress`, `Ingress`, `IngressClass`, `NetworkPolicy`,
`ServiceCIDR`

**node.yaml:** `RuntimeClass`

**policy.yaml:** `PodDisruptionBudget`

**rbac.yaml:** `ClusterRole`, `ClusterRoleBinding`, `Role`, `RoleBinding`

**scheduling.yaml:** `PriorityClass`

**storage.yaml:** `CSIDriver`, `CSINode`, `CSIStorageCapacity`, `StorageClass`,
`VolumeAttachment`, `VolumeAttributesClass`

This repository keeps the output of the separate `oas2tosca` tool for 1.35
at [`profiles/io/k8s/`](../../k8s/).

---

## Part 2 — Post-processing (manual)

The generated node types are flat: none derives from another. Post-processing
turns them into a DRY, working profile. Apply the steps in order. The overarching goals are:

1. **Introduce inheritance** to promote DRY (don't repeat yourself).
2. **Introduce capabilities and requirements** to formalize the allowed
   interactions between resources.
3. **Wire `spec` values across relationships** with `$get_property` /
   `$get_attribute` so template authors don't repeat them.

### Step 1 — Add the external profile import

The hand-written additions in the steps below use types from another profile.
Add `- profile: community.tosca.technology.base:0.2` (namespace `base`) to
`core.yaml` and `apps.yaml`, the files those additions go into. It provides the
`Root` node type, the `Bash` artifact type (Step 7), and, through its own
`community.tosca.core` import, the base capability and relationship types.

### Step 2 — Introduce the top-level `Resource` node type

Introduce a base `Resource` node type that all resource node types inherit from:

- **Define** the `metadata` property on `Resource`, inherited by all node types.
- The generated types already have no `apiVersion` or `kind` property, carry
  their `x-kubernetes-group-version-kind` metadata, and declare `status` as an
  attribute (Part 1, Step 2). The lifecycle artifacts hard-code the manifest's
  `apiVersion` and `kind` (Part 3).

### Step 3 — Separate cluster-scoped from namespaced resources

**Cluster-scoped** resources (not namespaced) derive directly from `Resource`:

- **core:** `Namespace`, `Node`, `PersistentVolume`
- **rbac:** `ClusterRole`, `ClusterRoleBinding`
- **storage:** `CSIDriver`, `CSINode`, `CSIStorageCapacity`, `StorageClass`,
  `VolumeAttachment`, `VolumeAttributesClass`
- **networking:** `IngressClass`, `IPAddress`, `ServiceCIDR`

Introduce a **`NamespacedResource`** node type for everything else:

- Derives from `Resource`.
- Has an optional requirement for a `Namespace` (via the `ScopedBy` relationship
  → `Scope` capability).
- Sets `metadata.namespace` to the name of the target namespace.
- All remaining node types derive from `NamespacedResource`.

### Step 4 — Introduce workload types

- **Pod:** a base `Pod`; a `Pod` that advertises the `Workload` capability and
  makes `labels` mandatory; and a `StandalonePod`.
- **`WorkloadController`:** a base node type from which all workload controllers
  (`Deployment`, `ReplicaSet`, `StatefulSet`, `DaemonSet`, …) derive. It defines
  a `pod` requirement for the pod workload it controls (via the `Controls`
  relationship). Derived classes set their pod template from the properties of
  the `pod` relationship's target.

### Step 5 — Introduce capabilities and requirements

Formalize the allowed interactions between resources using the profile's
capability and relationship types (defined in `core.yaml`):

| Capability | Advertised by | Consumed via relationship |
|---|---|---|
| `Scope` | `Namespace` | `ScopedBy` (namespaced resource → namespace) |
| `Identity` | `ServiceAccount` | `RunsAs` (pod → service account) |
| `Workload` | `Pod` | `Controls` (controller → pod), `Exposes` (service → pod) |

### Step 6 — Wire `spec` values across relationships

Where possible, set `spec` property values in the node types using
`$get_property` / `$get_attribute` across TOSCA relationships, rather than
requiring the template author to repeat them. This is done with `default:`
values on the spec fields. For example, `Deployment` defaults its
`selector.matchLabels` and `template.spec` from the pod it controls:

```yaml
spec:
  selector:
    default:
      matchLabels: {$get_property: [SELF, RELATIONSHIP, pod, TARGET, metadata, labels]}
  template:
    default:
      spec: {$get_property: [SELF, RELATIONSHIP, pod, TARGET, spec]}
```

### Step 7 — Wire lifecycle operations into the deployable types

Add `interfaces:` / `operations:` to the node types the orchestrator deploys,
pointing each operation at its Bash artifact (the `base:Bash` type imported in
Step 1). For example, on `Deployment`:

```yaml
interfaces:
  standard:
    operations:
      create:
        inputs:  { spec: {$get_property: [SELF, spec]} }
        outputs:
          spec: [SELF, spec]
          status: { mapping: [SELF, status], required: false }
        implementation:
          primary: { file: artifacts/deployment/create.sh, type: base:Bash }
      delete:
        implementation:
          primary: { file: artifacts/deployment/delete.sh, type: base:Bash }
```

An output is required unless it says otherwise, and an operation that succeeds without producing
a required output fails. So an output of a field the resource does not always report -- one the
OpenAPI schema does not list as required, such as `status` right after an apply, or a
`ServiceAccount`'s `automountServiceAccountToken`, `imagePullSecrets` and `secrets` -- is mapped
with `required: false`, as `status` is above.

Only the types that are actually deployed carry these — currently `Namespace`,
`StandalonePod`, `Service`, `ServiceAccount`, and `Deployment`. The artifacts
themselves are described in Part 3; which types still lack them is listed under
[Remaining work](#remaining-work).

---

## Part 3 — Implementation artifacts

Lifecycle artifacts stay minimal:

1. Build the manifest from `apiVersion` + `kind` (specific to the resource) plus
   `metadata`, `spec`, and any other resource-specific values.
2. Use **JSON** for the manifest to avoid YAML formatting glitches.
3. `kubectl apply` the manifest.

Which types currently have `create.sh` / `delete.sh` (and which are still
missing) is listed under [Remaining work](#remaining-work).

---

## Known issues / generator limitations

- **`IntOrString`.** Kubernetes' `IntOrString` is a union type: a field that
  accepts either an `int32` or a `string` (a port given as the number `8080` or
  the named port `"http"`). TOSCA has no union (or `any`) type, so it derives
  from `string` (see `intstr.yaml`). A numeric value must be quoted (`"8080"`),
  and design-time validation can enforce only "string", not "int32 *or* string".
- **Untyped values.** A schema that accepts any JSON value derives from
  `string`.
- **No range checks from integer formats.** `int32` and `int64` fields accept
  any integer.

---

## Remaining work

Work still needed to complete the `io.kubernetes:1.35` profile.

### Lifecycle scripts

3.0 ships `create.sh` / `delete.sh` only for `Namespace`, `StandalonePod`,
`Service`, `ServiceAccount`, and `Deployment`. These defined types have no scripts
yet, so the orchestrator cannot deploy them:

- `ConfigMap`, `Secret`
- `PersistentVolumeClaim`
- `Pod` (only `StandalonePod` has artifacts)
- `ReplicaSet`, `StatefulSet`, `DaemonSet`
- `Ingress`, `NetworkPolicy`
- `ClusterRole`, `ClusterRoleBinding`, `Role`, `RoleBinding`

Each follows the same pattern as `artifacts/deployment/create.sh` — render the
resource spec from properties, `kubectl apply`, wait for readiness, emit outputs —
then wire it into the type per Step 7.

### API groups

Every GA API group is generated (Part 1). Lifecycle scripts and the hand-written
post-processing of Part 2 cover only `core`, `apps`, `storage`, `networking` and
`rbac`; the other groups (`batch`: `Job`, `CronJob`, among them) have their
generated types only.

### Service convenience subtypes (decision)

3.0's single `Service`, discriminated by `spec.type`, is fully expressive but
verbose for common cases. Either keep it as-is (most consistent with the
OpenAPI-driven design; recommended unless templates start accumulating
boilerplate) or layer `ClusterIPService` / `NodePortService` /
`LoadBalancerService` on top with `spec.type` defaulted.

### Helper scripts (decision)

`io.kubernetes:2.5` shipped `artifacts/template.sh` and `artifacts/patterns.sh`
(manifest templating helpers); 3.0 has only `common_lib.sh`. Decide whether the
templating helpers are still useful — they predate the OpenAPI-driven approach and
may be obsolete now that every type carries its own spec schema.

### Open design questions

1. **Volume sources as node types vs. data types.** 2.5 made each volume source a
   node type, which let templates wire them as first-class topology nodes; 3.0
   treats them as data. If the first-class modeling is genuinely useful, consider
   reintroducing it as a thin layer over the generated types — but only when a
   concrete use case appears.
2. **`Pod` vs. `StandalonePod`.** 3.0 distinguishes the two. Confirm the semantics
   are clear to template authors before adding `Pod` lifecycle scripts.
