# TOSCA Kubernetes Profile (`io.kubernetes:1.35`)

TOSCA type definitions for Kubernetes resources. The profile is generated
semi-automatically from the upstream Kubernetes OpenAPI specification with
[`oas2tosca`](https://github.com/ubicity-corp/oas2tosca) and then post-processed.
It is the basis for all current Kubernetes work in this repository; the
hand-written `io.kubernetes:2.5` profile is retained only for backward
compatibility.

## What it models

Each Kubernetes resource kind is a TOSCA **node type** that mirrors its manifest:
a `metadata` property and a resource-specific, fully-typed `spec` property, so
resource definitions can be validated at design time. The node types form an
inheritance hierarchy (`Resource` → `NamespacedResource` → …) and are wired
together with capability and relationship types — `Scope`/`ScopedBy`,
`Identity`/`RunsAs`, `Workload`/`Controls`/`Exposes` — that formalize how
resources interact.

## Layout

| File | Contents |
|------|----------|
| `profile.yaml` | Top-level file; declares `io.kubernetes:1.35` and imports the rest. |
| `core.yaml`, `apps.yaml`, `storage.yaml`, `networking.yaml`, `rbac.yaml` | Resource node types, one file per Kubernetes API group. |
| `meta.yaml`, `resource.yaml`, `runtime.yaml`, `intstr.yaml` | `apimachinery` data types (`ObjectMeta`, `Quantity`, `RawExtension`, `IntOrString`). |
| `artifacts/` | Bash lifecycle scripts (`create.sh` / `delete.sh`) for the deployable types. |

## Documentation

- **[`GENERATING.md`](GENERATING.md)** — how the profile is generated from the
  OpenAPI and post-processed, plus the remaining work to complete it.

## Status

Generated and partially finished: only the stable `v1` version of each resource
is converted, only the API groups listed above are aggregated (`batch`/`Job` is
not yet included), and only some types carry lifecycle scripts. See
[`GENERATING.md`](GENERATING.md) → *Remaining work* for the current gaps.
