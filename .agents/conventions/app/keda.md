# KEDA Conventions

The `keda/dependencies` component scales an app to zero while any of its external dependencies is unreachable, and runs exactly `REPLICAS` pods when all of them are up. It is an on/off gate, not autoscaling: the HPA KEDA creates has min == max, so it never trips `KubeHpaMaxedOut`.

Availability comes from Prometheus blackbox probes (`probe_success`) in `monitoring`.

## Usage

```yaml
components:
  - ../../../../components/keda/dependencies
postBuild:
  substitute:
    APP: *app
    DEPENDS_ON: "nfs|postgres"
```

## `DEPENDS_ON` values

`DEPENDS_ON` is a `|`-separated list of probe names (the job is `probe/monitoring/<name>`). The app only runs when every listed probe is up.

| Probe | Dependency |
|---|---|
| `nfs` | NFS (port 2049) |
| `postgres` | Postgres (port 5432) |
| `immich` | VectorChord (port 6001) |

A new dependency only needs a new probe; no new component.

## `postBuild.substitute` variables

| Variable | Default | Notes |
|---|---|---|
| `APP` | — | Required — use `*app` |
| `DEPENDS_ON` | — | Required — see above |
| `REPLICAS` | `1` | Pods to run while all dependencies are up |
| `COOLDOWN_PERIOD` | `300` | Seconds before scaling back up |
| `CONTROLLER` | `Deployment` | Override for StatefulSet etc. |
