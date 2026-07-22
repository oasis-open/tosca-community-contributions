# `community.tosca.technology.*`

Technology-specific profiles that build on the community `core` and `abstract.*`
layers.

## Kubernetes

There is **no Kubernetes profile under this directory.** The community's
Kubernetes resource profile is the auto-generated, reverse-DNS profile at:

- [`profiles/io/kubernetes/1.35`](../../../io/kubernetes/1.35) —
  `io.kubernetes:1.35`, versioned by the Kubernetes distribution it was generated
  from. See its [`GENERATING.md`](../../../io/kubernetes/1.35/GENERATING.md)
  for the OpenAPI-to-TOSCA generation procedure.

The two former copies here — the generated `community.tosca.technology.k8s` and
the hand-authored `community.tosca.technology.kubernetes` — were retired following
the 2026-07-22 community decision (issue I22); see
[`docs/profile-naming.md`](../docs/profile-naming.md). The durable design
rationale for modeling Kubernetes with TOSCA now lives in
[`docs/kubernetes-modeling.md`](../docs/kubernetes-modeling.md).

## `base`

- [`base`](base) — `community.tosca.technology.base:0.1`, the shared technology
  base profile (Root and common building blocks that technology profiles import).
