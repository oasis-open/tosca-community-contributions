# Migrating from `io.kubernetes:2.5` to `io.kubernetes:3.0`

`io.kubernetes:3.0` is a near-complete rewrite of the Kubernetes
profile, generated semi-automatically from the upstream Kubernetes
OpenAPI specification. It is intended to be the basis for all future
Kubernetes work in this repository. The 2.5 profile remains in the
tree for backward compatibility but should not receive new features.

This document inventories the differences between the two profiles
and proposes a phased plan for closing the gaps.

## Differences

### 1. Functionality already extracted

These pieces of `io.kubernetes:2.5` no longer belong in a Kubernetes
profile and have been moved to dedicated profiles:

| 2.5 type            | New location          |
|---------------------|-----------------------|
| `HelmApp`           | `sh.helm:3.0`         |
| `HelmChart` (artifact type) | `sh.helm:3.0` |
| `Compute` (KubeVirt VM) | `io.kubevirt:2.5` |

No further action required.

### 2. Node types missing in 3.0

| 2.5 type | Notes |
|----------|-------|
| `Job`, `CronJob` | Entire `batch/v1` API group not yet generated. |
| `ClusterIPService`, `NodePortService`, `LoadBalancerService` | 3.0 collapses these into a single generic `Service`, discriminated by `spec.type`. Functionally equivalent but lacks convenience subtypes. |
| `EmptyDir`, `HostPath`, `Projected`, `Image`, `DownwardAPI`, `Local`, `NFS`, `FibreChannel`, `Iscsi` | Volume sources. 3.0 models these as data types under `Volume`/`PersistentVolume` source schemas rather than as standalone node types. This is a deliberate modeling change, not a gap. |
| `Volume`, `PersistentVolume` (node form) | Same as above — represented in 3.0 as resource types only, not as separate volume-source node types. |

### 3. Node types present in 3.0 but lacking lifecycle scripts

3.0 defines the following types but provides no `create.sh` /
`delete.sh` implementations, so the orchestrator cannot deploy them
as-is:

- `ConfigMap`, `Secret`
- `PersistentVolumeClaim`
- `Pod` (only `StandalonePod` has artifacts)
- `ReplicaSet`, `StatefulSet`, `DaemonSet`
- `Ingress`, `NetworkPolicy`
- `ClusterRole`, `ClusterRoleBinding`, `Role`, `RoleBinding`

Currently 3.0 has lifecycle artifacts only for: `Namespace`,
`StandalonePod`, `Service`, `ServiceAccount`, `Deployment`.

### 4. Capability and relationship vocabulary

This is a deliberate redesign in 3.0, not a gap, but service
templates that target 2.5 will need translation.

| 2.5 | 3.0 equivalent |
|-----|----------------|
| `Label` (capability) | `Workload` |
| `Claimable` (capability) | dropped — claims modeled differently |
| `ServiceEndpoint` (capability) | `Exposes` (relationship) |
| `References` (relationship) | dropped — direct property reference |
| `Claims` (relationship) | dropped |
| `RoutesTo` (relationship) | `Exposes` |
| `Selects` (relationship) | `Exposes` |
| `Consumes` (relationship) | `RunsAs` for service accounts; otherwise dropped |
| (none) | `Identity` (capability) — new in 3.0 |
| (none) | `Workload` (capability) — new in 3.0 |
| (none) | `Controls` (relationship) — new in 3.0 |

### 5. Property paths

Several inherited properties are nested differently. The most common
trap is the namespace name:

- 2.5: `{$get_property: [..., name]}`
- 3.0: `{$get_property: [..., metadata, name]}`

`Namespace` and other top-level resources expose their name via the
inherited `metadata.name` field rather than a top-level `name`
property.

### 6. Helper scripts

`io.kubernetes:2.5` ships `artifacts/template.sh` and
`artifacts/patterns.sh` (manifest templating helpers). 3.0 has only
`common_lib.sh`. Decide whether the templating helpers are still
useful before reintroducing them.

## Recommended action plan

The plan is ordered by impact. Each phase is independently
shippable.

### Phase 1 — Add missing lifecycle scripts (highest priority)

Without `create.sh` / `delete.sh` for the common workload and config
types, 3.0 cannot replace 2.5 in production templates. Add scripts
for:

1. `ConfigMap`, `Secret`
2. `PersistentVolumeClaim`
3. `ReplicaSet`, `StatefulSet`, `DaemonSet`
4. `ClusterRole`, `ClusterRoleBinding`, `Role`, `RoleBinding`
5. `Ingress`, `NetworkPolicy`
6. `Pod` (in addition to existing `StandalonePod`)

Each follows the same pattern as the existing `deployment/create.sh`:
render the resource spec from properties, `kubectl apply`, wait for
readiness, emit outputs.

### Phase 2 — Add `batch/v1` types

Generate `Job` and `CronJob` from the OpenAPI spec (or hand-write if
the generator isn't easily re-runnable for one API group). Provide
lifecycle scripts.

### Phase 3 — Decide on Service convenience subtypes

3.0's single `Service` is fully expressive but verbose for common
cases. Two options:

- **Keep as-is.** Force callers to set `spec.type` explicitly. Most
  consistent with the OpenAPI-driven design.
- **Add convenience subtypes.** Layer `ClusterIPService`,
  `NodePortService`, `LoadBalancerService` on top of `Service` with
  `spec.type` defaulted. Easier ergonomics, mild redundancy.

Recommendation: keep as-is unless service templates start
accumulating boilerplate. The 2.5 subtypes were primarily ergonomic
and don't justify divergence from the OpenAPI mapping.

### Phase 4 — Translate substituting templates and downstream profiles

Audit consumers:

- `io.kubevirt:2.5` — already migrated to import `io.kubernetes:3.0`.
- `sh.helm:3.0` — built against 3.0.
- `com.ubicity.abstract.platform:0.1` substitutions — verify none
  reference 2.5-specific types (`Label`, `Selects`, etc.).
- Service templates in `tosca-svcs` — translate any usage of
  removed/renamed capabilities and relationships.

### Phase 5 — Deprecate `io.kubernetes:2.5`

Once Phases 1–4 are complete and downstream consumers are migrated,
mark 2.5 as deprecated in its README and stop including it in the
default onboarding script. Retain the directory for archival.

## Open design questions

1. **Volume sources as node types vs. data types.** 2.5 made each
   volume source a node type, which let templates wire them as
   first-class topology nodes. 3.0 treats them as data. If the
   first-class modeling is genuinely useful, we may want to
   reintroduce it as a thin layer on top of the generated types —
   but only when a concrete use case appears.

2. **Pod vs. StandalonePod.** 3.0 distinguishes the two. Confirm
   the semantics are clear to template authors before adding `Pod`
   lifecycle scripts.

3. **Helper scripts (`template.sh`, `patterns.sh`).** Worth
   reintroducing? They predate the OpenAPI-driven approach and may
   be obsolete if every type now carries its own spec schema.
