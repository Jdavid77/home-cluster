# KEDA Conventions

KEDA components scale an app down to zero when its external dependencies become unreachable. Availability is detected via Prometheus probes on the dependency's port.

## Components

Pick the component that matches the app's dependencies:

| Component | Use when app depends on |
|---|---|
| `keda/postgres` | Postgres |
| `keda/nfs` | NFS |
| `keda/vectorchord` | VectorChord |
| `keda/nfs-postgres` | NFS **and** Postgres |
| `keda/nfs-vectorchord` | NFS **and** VectorChord |

Add the chosen component to `ks.yaml`:

```yaml
components:
  - ../../../../components/keda/postgres   # example
```

## `postBuild.substitute` variables

| Variable | Default | Notes |
|---|---|---|
| `APP` | — | Required — use `*app` |
| `COOLDOWN_PERIOD` | `300` | Seconds before scaling back up |
| `MIN_REPLICAS` | `0` | Set to `1` to disable scale-to-zero |
| `MAX_REPLICAS` | `1` | |
| `CONTROLLER` | `Deployment` | Override for StatefulSet etc. |
