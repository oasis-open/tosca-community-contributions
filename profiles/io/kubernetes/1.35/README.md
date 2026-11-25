# TOSCA Kubernetes Profile (`io.kubernetes:1.35`)

TOSCA type definitions for Kubernetes resources. The profile is generated from
the upstream Kubernetes OpenAPI specification with `oas2tosca --kubernetes` from
[any2tosca](https://github.com/ubicity-corp/any2tosca) and then post-processed.
It is the basis for all current Kubernetes work in this repository.

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
| `core.yaml`, `apps.yaml`, `batch.yaml`, `networking.yaml`, `rbac.yaml`, `storage.yaml`, … | Resource node types and their data types, one file per GA Kubernetes API group (the `resource.k8s.io` group is `dra.yaml`). |
| `apiextensions.yaml`, `apiregistration.yaml` | `CustomResourceDefinition` and `APIService`. |
| `meta.yaml`, `resource.yaml`, `runtime.yaml`, `intstr.yaml` | `apimachinery` data types (`ObjectMeta`, `Quantity`, `RawExtension`, `IntOrString`). |
| `artifacts/` | Bash lifecycle scripts (`create.sh` / `delete.sh`) for the deployable types. |

## Documentation

- **[`GENERATING.md`](GENERATING.md)** — how the profile is generated from the
  OpenAPI and post-processed, plus the remaining work to complete it.

## Status

Generated and partially finished: every GA API group is generated (alpha and
beta versions are not), but the hand-written post-processing (inheritance,
capabilities, requirements, lifecycle wiring) covers only `core`, `apps`,
`storage`, `networking` and `rbac`, and only some types carry lifecycle scripts.
See [`GENERATING.md`](GENERATING.md) → *Remaining work* for the current gaps.
