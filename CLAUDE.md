# home-cluster

Monorepo for a self-hosted homelab: a Talos Linux Kubernetes cluster managed by Flux CD, plus the surrounding infrastructure.

## Top-level directories

| Directory | Purpose |
|---|---|
| `k8s/` | All cluster workloads — Flux Kustomizations, HelmReleases, components |
| `talos/` | Node configuration via `topf` (`topf.yaml` + patch tree under `all/`, `control-plane/`, `worker/`, `node/`) |
| `terraform/` | External service infrastructure (Akeyless, Authentik, Garage) |
| `bootstrap/` | One-time cluster init — do not modify during normal operations |

## Conventions

See `.agents/conventions/` for detailed working conventions:

- `.agents/conventions/app/` — how to add and configure apps in `k8s/apps/`
- `.agents/conventions/repo/structure.md` — extended notes on each directory
- `.agents/conventions/docs/style.md` — formatting rules shared by every page in `docs/`
- `.agents/conventions/docs/runbooks.md` — how to structure a runbook in `docs/runbooks/`
- `.agents/conventions/docs/migrations.md` — how to write a migration record in `docs/migrations/`
