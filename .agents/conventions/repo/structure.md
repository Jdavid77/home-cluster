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
| `components/volsync/remote` | Remote restic backup via Cloudflare R2 |
| `components/keda/dependencies` | KEDA ScaledObject that scales an app to zero while its dependencies (NFS, Postgres, …) are down |
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
| `terraform/garage/` | Garage S3-compatible local storage (used by VolSync local backups) |
| `terraform/cloudflare/` | Cloudflare security rules (WAF custom rules) and the `github_webhook` IP list |

When adding a new Akeyless secret path, edit `terraform/akeyless/`. Do not mix concerns across workspaces.

Cloudflare security rules: `ref` is `<action>-<what it matches>` in kebab-case (e.g. `block-verified-bots`) and never changes once applied, since a new ref recreates the rule. `description` is `<Action> <what>[ for <scope>]` in sentence case and can change freely.

---

## `bootstrap/` — One-Time Cluster Initialization

Used only when bootstrapping the cluster from scratch. Do not modify during normal operations.

- `helmfile.yaml` / `crds.helmfile.yaml` — install Flux Operator and CRDs via Helm before Flux is running.
- `secrets/` — SOPS-encrypted bootstrap secrets (age key, GitHub App credentials).

---

## NAS host (Docker Compose)

The OpenMediaVault NAS runs its services with Docker Compose. They're in a separate repo, [omv-compose](https://github.com/Jdavid77/omv-compose), managed by the OMV compose plugin. Cluster apps keep their databases in its `postgres18` stack, and Immich uses `vectorchord`.
