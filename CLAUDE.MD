# home-cluster

Monorepo for a self-hosted homelab: a Talos Linux Kubernetes cluster managed by Flux CD, plus the surrounding infrastructure.

## Top-level directories

| Directory | Purpose |
|---|---|
| `k8s/` | All cluster workloads — Flux Kustomizations, HelmReleases, components |
| `talos/` | Node configuration via `talhelper` (`talconfig.yaml` + `patches/`) |
| `terraform/` | External service infrastructure (Akeyless, Authentik, Backblaze, Garage) |
| `bootstrap/` | One-time cluster init — do not modify during normal operations |
| `omv/` | Separate NAS host running Docker Compose — not part of the cluster |

## Conventions

See `.agents/conventions/` for detailed working conventions:

- `.agents/conventions/app/` — how to add and configure apps in `k8s/apps/`
- `.agents/conventions/repo/structure.md` — extended notes on each directory
