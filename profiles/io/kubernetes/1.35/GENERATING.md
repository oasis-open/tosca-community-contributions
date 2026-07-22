# Generating and Post-Processing the Kubernetes Profile

**Status:** Working procedure — cleaned up from the post-processing notes in
[`README.md`](README.md) (2026-07-21). A couple of items carry review notes (the
v1.3→v2.0 edit list in Step 1; `IntOrString` in Step 2).
**Scope:** How `io.kubernetes:1.35` is (re)generated from the upstream Kubernetes
OpenAPI specification with [`oas2tosca`](https://github.com/ubicity-corp/oas2tosca),
and the manual post-processing that turns the raw generator output into a working
TOSCA v2.0 profile.

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

To pin a specific Kubernetes version instead, set `BRANCH` explicitly (e.g.
`BRANCH=release-1.34`).

### 2. Convert to TOSCA with `oas2tosca`

`oas2tosca` generates a set of TOSCA profiles whose names follow the Kubernetes
API groups:

```bash
oas2tosca -i k8s-openapi-v2.json -o k8s-profiles
```

Generator characteristics to keep in mind:

- It currently emits **TOSCA v1.3** (post-processing converts to v2.0 — Part 2, Step 1).
- It uses **heuristics** to decide when to emit a TOSCA *data type* versus a *node type*.
- TOSCA has no `any` data type, so `any`-typed values are emitted as **strings**.
- It converts **only the `v1` version** of each resource. The check is hardcoded
  (`if version != 'v1': ... return`, in both the node-type and data-type paths of
  `swagger.py`), so when the OpenAPI defines a resource at several versions in the
  same group (`v1`, `v1beta1`, `v1alpha1`, `v2`, …) only the exact-`v1` schema is
  kept and the rest are silently skipped. A kind that exists *only* at a non-`v1`
  version is omitted from the generated profile entirely and must be added by hand.

### 3. Aggregate the per-API-group files into the profile

The generator emits one file per API group under `io/k8s/...`. Copy them into the
profile under its flat file names:

```bash
cp io/k8s/apimachinery/pkg/apis/meta/profile.yaml     io/kubernetes/1.35/meta.yaml
cp io/k8s/apimachinery/pkg/api/resource/profile.yaml  io/kubernetes/1.35/resource.yaml
cp io/k8s/apimachinery/pkg/runtime/profile.yaml       io/kubernetes/1.35/runtime.yaml
cp io/k8s/apimachinery/pkg/util/intstr/profile.yaml   io/kubernetes/1.35/intstr.yaml
cp io/k8s/api/core/profile.yaml                        io/kubernetes/1.35/core.yaml
cp io/k8s/api/apps/profile.yaml                        io/kubernetes/1.35/apps.yaml
cp io/k8s/api/storage/profile.yaml                     io/kubernetes/1.35/storage.yaml
cp io/k8s/api/networking/profile.yaml                  io/kubernetes/1.35/networking.yaml
cp io/k8s/api/rbac/profile.yaml                        io/kubernetes/1.35/rbac.yaml
```

At this stage every generated node type derives directly from `tosca.nodes.Root`,
one node type per Kubernetes resource kind:

Raw generated node types, by file:

**core.yaml:** `Namespace`, `Binding`, `ConfigMap`, `Endpoints`, `Event`,
`LimitRange`, `PersistentVolumeClaim`, `Pod`, `PodTemplate`,
`ReplicationController`, `ResourceQuota`, `Secret`, `ServiceAccount`, `Service`,
`Node`, `PersistentVolume`

**apps.yaml:** `ControllerRevision`, `DaemonSet`, `Deployment`, `ReplicaSet`,
`StatefulSet`

**rbac.yaml:** `ClusterRoleBinding`, `ClusterRole`, `RoleBinding`, `Role`

**storage.yaml:** `CSIDriver`, `CSINode`, `CSIStorageCapacity`, `StorageClass`,
`VolumeAttachment`, `VolumeAttributesClass`

**networking.yaml:** `IngressClass`, `IPAddress`, `Ingress`, `NetworkPolicy`,
`ServiceCIDR`

This list covers only the API groups aggregated in Step 3 (`core`, `apps`,
`storage`, `networking`, `rbac`) at their `v1` version. Other groups are not
included — notably `batch` (`Job`, `CronJob`); see [Remaining work](#remaining-work).

---

## Part 2 — Post-processing (manual)

The raw output is a flat list of node types, each deriving from
`tosca.nodes.Root`. Post-processing turns it into a DRY, validated, working v2.0
profile. Apply the steps in order. The overarching goals are:

1. **Introduce inheritance** to promote DRY (don't repeat yourself).
2. **Introduce capabilities and requirements** to formalize the allowed
   interactions between resources.
3. **Wire `spec` values across relationships** with `$get_property` /
   `$get_attribute` so template authors don't repeat them.

### Step 1 — Convert TOSCA v1.3 → v2.0

The generator emits v1.3. Convert each aggregated file to v2.0. (As of
2026-07-21 all aggregated files are v2.0; the edits below were applied to the
remaining `meta`/`resource`/`runtime`/`intstr`/`networking`/`rbac`/`storage`
files.)

The concrete edits:

1. **Version.** `tosca_definitions_version: tosca_simple_yaml_1_3` → `tosca_2_0`.
2. **Profile naming.** Drop the per-file `namespace: io.k8s.<group>` line. In v2.0
   the profile name is declared once, in `profile.yaml` (`profile:
   io.kubernetes:1.35`); the aggregated sub-files carry no `profile:` /
   `namespace:` of their own.
3. **Imports.** Three edits:
   - **Syntax.** `- file: X` + `namespace_prefix: Y` → `- url: X` + `namespace: Y`.
   - **Repoint siblings to the aggregated files.** The generator imports sibling
     profiles by their full dotted name (`- file: io.k8s.apimachinery.pkg.apis.meta`);
     after aggregation (Part 1, Step 3) these must point at the local file names
     (`- url: meta.yaml`).
   - **Add the external profile import** the generator never emits but the
     post-processing needs: `community.tosca.technology.base:0.1` (`base`). It
     provides the `Root` node type, the `Bash` artifact type (used in Step 8),
     and — via its own `community.tosca.core` import — the base
     capability/relationship types and the `$in_range` function. The `cluster`
     requirement also targets `base:Kubernetes` / `base:KubernetesCluster`,
     expected in the base profile.
4. **Property constraints → validation.** v1.3
   `constraints:` / `- in_range: [MIN, MAX]` becomes v2.0
   `validation:` / `$in_range: [$value, [MIN, MAX]]` — note the 2-arg community
   `$in_range` signature with the range as a nested list.
5. **`$in_range` import.** `in_range` is a v1.3 *built-in* but a v2.0 *function*
   (defined in `community.tosca.core` and re-exported by
   `community.tosca.technology.base`). Any file that uses it therefore needs the
   `- profile: community.tosca.technology.base:0.1` import (namespace `base`, from
   which `$in_range` resolves unprefixed). Files with no `in_range` need no such
   import. (`meta.yaml`, `networking.yaml`, and `storage.yaml` required it.)

> **Note.** The full conversion (2026-07-21) confirmed these are the only
> constructs present in the converted files: the version keyword, the per-file
> `namespace:`, `file:`/`namespace_prefix:` imports, and `in_range` constraints
> (plus the `$in_range` import above). No other v1.3-only constructs
> (`occurrences`, other constraint operators, function-syntax differences)
> appeared.

### Step 2 — Fix known generator bugs

- **`PodTemplate`.** `oas2tosca` emits `PodTemplate` as a *node type* with a
  `template` property of type `PodTemplateSpec`. It should be a **data type**.
  Convert it by hand.
- **`IntOrString`.** Kubernetes' `IntOrString` is a *union* type — a field that
  accepts either an `int32` or a `string` (e.g. a port given as the number `8080`
  or the named port `"http"`). TOSCA has no union (or `any`) type, so the
  generator emits it as `derived_from: string` (see `intstr.yaml`). The
  consequence is that the integer branch is lost: a numeric value must be quoted
  (`"8080"`), and design-time validation can enforce only "string," not "int32
  *or* string." The profile currently keeps the `string` modeling.
  > **Note.** The right long-term modeling of `IntOrString` is open —
  > string-with-convention, a custom validation function, or accepting the
  > limitation. TOSCA provides no native union type.
- **Empty values.** The generator sometimes emits an empty scalar where a value
  is expected (e.g. `group:`, `Examples:`); replace these with an empty map
  (`group: {}`, `Examples: {}`) so the file is valid.

### Step 3 — Introduce the top-level `Resource` node type

Introduce a base `Resource` node type that all resource node types inherit from:

- **Keep** the `metadata` property (inherited by all node types).
- **Remove** the `apiVersion` and `kind` properties — these are hard-coded in the
  implementation artifacts.
- **Keep** each type's `x-kubernetes-group-version-kind` metadata block. The
  `apiVersion`/`kind` *properties* are removed, but the group/version/kind
  *metadata* stays — the lifecycle artifacts read it to build the manifest.
- Turn `status` into an **attribute** rather than a property, and drop its
  `required` keyword.

### Step 4 — Separate cluster-scoped from namespaced resources

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

### Step 5 — Introduce workload types

- **Pod:** a base `Pod`; a `Pod` that advertises the `Workload` capability and
  makes `labels` mandatory; and a `StandalonePod`.
- **`WorkloadController`:** a base node type from which all workload controllers
  (`Deployment`, `ReplicaSet`, `StatefulSet`, `DaemonSet`, …) derive. It defines
  a `pod` requirement for the pod workload it controls (via the `Controls`
  relationship). Derived classes set their pod template from the properties of
  the `pod` relationship's target.

### Step 6 — Introduce capabilities and requirements

Formalize the allowed interactions between resources using the profile's
capability and relationship types (defined in `core.yaml`):

| Capability | Advertised by | Consumed via relationship |
|---|---|---|
| `Scope` | `Namespace` | `ScopedBy` (namespaced resource → namespace) |
| `Identity` | `ServiceAccount` | `RunsAs` (pod → service account) |
| `Workload` | `Pod` | `Controls` (controller → pod), `Exposes` (service → pod) |

### Step 7 — Wire `spec` values across relationships

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

### Step 8 — Wire lifecycle operations into the deployable types

Add `interfaces:` / `operations:` to the node types the orchestrator deploys,
pointing each operation at its Bash artifact (the `base:Bash` type imported in
Step 1). For example, on `Deployment`:

```yaml
interfaces:
  Standard:
    operations:
      create:
        inputs:  { spec: {$get_property: [SELF, spec]} }
        outputs: { spec: [SELF, spec], status: [SELF, status] }
        implementation:
          primary: { file: artifacts/deployment/create.sh, type: base:Bash }
      delete:
        implementation:
          primary: { file: artifacts/deployment/delete.sh, type: base:Bash }
```

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

- **`oas2tosca` emits TOSCA v1.3** — must be converted to v2.0 (Step 1).
- **Only `v1` resources are converted** — the `version == 'v1'` check is hardcoded,
  so multi-version resources keep only their `v1` schema and non-`v1`-only kinds
  are dropped (Part 1, Step 2). One of the reasons the tool is slated for
  replacement by `any2tosca`.
- **`any` → string** — TOSCA has no `any` data type (Part 1, Step 2).
- **`PodTemplate` emitted as a node type** instead of a data type (Step 2).
- **`IntOrString`** — Kubernetes union type (`int32` or `string`) emitted as
  `derived_from: string`, losing the integer branch (Step 2). *Requires review.*

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
then wire it into the type per Step 8.

### Missing API groups

Only `core`/`apps`/`storage`/`networking`/`rbac` were aggregated (Part 1, Step 3).
Other groups the generator produced are not included — notably `batch` (`Job`,
`CronJob`). Aggregate the needed groups (or hand-write the types if the generator
isn't easily re-runnable for one group) and add their lifecycle scripts.

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
