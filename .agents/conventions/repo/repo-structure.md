# Repository Structure

This is a home-cluster monorepo. It manages a Talos Linux Kubernetes cluster and the surrounding infrastructure. Each top-level directory has a distinct responsibility.

---

## `k8s/` — Flux GitOps

The main operational area. All cluster workloads live here and are reconciled by Flux.

### `k8s/flux/`

The Flux entrypoint. `cluster.yaml` defines the two root Kustomizations (`repos` and `apps`). Changes here affect the entire cluster.

`k8s/flux/repos/oci/` declares all `OCIRepository` sources (one file per Helm chart). When adding a new app:
- If it has its own Helm chart → add a new OCIRepository file here following the existing pattern.
- If it is a generic workload → reference the existing `app-template` OCIRepository (already declared), no new file needed.

### `k8s/apps/`

Namespaced application deployments. Structure:

```
k8s/apps/<namespace>/<app>/ks.yaml       # Flux Kustomization
k8s/apps/<namespace>/<app>/app/          # kustomization.yaml + manifests
```

See `.agents/conventions/app/` for detailed conventions on how to write these files.

### `k8s/components/`

Shared reusable Kustomize components included via `components:` in `ks.yaml`. Available components:

| Path | Purpose |
|---|---|
| `components/volsync/local` | Local restic backup via Garage S3 |
| `components/volsync/remote` | Remote restic backup via Backblaze B2 |
| `components/keda/postgres` | KEDA ScaledObject to scale down postgres before VolSync |
| `components/alerts/` | Alerting rules |
| `components/flux/` | Flux-related components |
| `components/grafana/` | Grafana dashboards/datasources |
| `components/middlewares/` | Envoy middleware configs |
| `components/storage/` | Storage classes |

Do not add app-specific logic to components. Components must remain generic and parameterised via `postBuild.substitute`.

---

## `talos/` — Node Configuration

Talos Linux machine configuration managed with `talhelper`.

- **Edit**: `talconfig.yaml` (cluster/node declarations) and `patches/` (Talos config patches).
- **Never edit**: `clusterconfig/` — this is generated output from `talhelper genconfig`. Changes there will be overwritten.

---

## `terraform/` — External Service Infrastructure

Each subdirectory is an independent Terraform workspace, auto-planned on PR by Atlantis (`atlantis.yaml`).

| Workspace | Manages |
|---|---|
| `terraform/akeyless/` | Akeyless secrets, roles, API keys |
| `terraform/authentik/` | Authentik SSO — OIDC clients, proxy providers, sources |
| `terraform/backblaze/` | Backblaze B2 buckets (used by VolSync remote backups) |
| `terraform/garage/` | Garage S3-compatible local storage (used by VolSync local backups) |

When adding a new Akeyless secret path, edit `terraform/akeyless/`. When adding a new B2 bucket, edit `terraform/backblaze/`. Do not mix concerns across workspaces.

---

## `bootstrap/` — One-Time Cluster Initialization

Used only when bootstrapping the cluster from scratch. Do not modify during normal operations.

- `helmfile.yaml` / `crds.helmfile.yaml` — install Flux Operator and CRDs via Helm before Flux is running.
- `secrets/` — SOPS-encrypted bootstrap secrets (age key, GitHub App credentials).

---

## `omv/` — NAS Host (Docker Compose)

This directory manages a separate physical host running OpenMediaVault with Docker Compose. It is **not** part of the Kubernetes cluster.

Services in `omv/docker/` that the cluster depends on:

| Service | Role |
|---|---|
| `postgres18/` | Shared PostgreSQL instance — cluster apps connect to this for their databases |
| `vectorchord/` | pgvector-compatible Postgres for vector workloads |
| `pihole/` | DNS server for the local network |
| `exit-node/` | Tailscale exit node |

Changes here are applied manually on the OMV host. There is no GitOps reconciliation for this directory.
