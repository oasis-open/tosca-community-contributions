# com.ubicity.kubernetes:2.5

TOSCA profile for installing and operating Kubernetes clusters.

Distinct from `io.kubernetes` (which models Kubernetes *API
resources* like Pod, Service, Deployment). This profile covers the
*cluster lifecycle* — installing the control plane and worker nodes
for specific Kubernetes distributions.

## Node types

- **Kubectl** — installation of the `kubectl` CLI tool.
- **KubernetesController**, **KubernetesWorker** — abstract base
  types for any Kubernetes cluster.
- **K3sController**, **K3sWorker** — k3s (Rancher's lightweight
  Kubernetes).
- **K0sController**, **K0sWorker** — k0s (Mirantis's zero-friction
  Kubernetes).
- **MicroK8sController**, **MicroK8sWorker** — Canonical's MicroK8s.
- **KubeadmController**, **KubeadmWorker** — upstream kubeadm.
- **Minikube** — single-node development cluster.
- **Kubernetes** — apt-installable Kubernetes packages (`kubelet`,
  `kubeadm`, `kubectl`).
- **ManagedKubernetes** — abstract base type for cloud-managed
  clusters (EKS, AKS, GKE).
