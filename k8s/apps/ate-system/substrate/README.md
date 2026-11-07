# Agent Substrate

[Agent Substrate](https://github.com/kagent-dev/substrate) running in `ate-system`. It is installed as five Flux Kustomizations, all defined in `ks.yaml`.

## Layout

| Directory | Kustomization | What it deploys |
|---|---|---|
| `crds/` | `substrate-crds` | Substrate CRDs |
| `podcert/` | `substrate-podcert` | podcert controller and its CA pools (`service-dns`, `pod-identity`, `postgres`) |
| `postgres/` | `substrate-postgres` | Postgres StatefulSet (app-template), a NetworkPolicy, and the `substrate-db-init` Job that runs `config/setup.sql` |
| `atelet/` | `substrate-atelet` | atelet DaemonSet, which stores snapshots in Garage over S3 |
| `app/` | `substrate` | ate-api-server, controller, IdP, router, egress, and the actor-id CA pools |

## Install order

```
substrate-crds ─────┬─> substrate-atelet ─┐
substrate-podcert ──┘                     ├─> substrate
substrate-postgres ───────────────────────┘
```

`substrate` installs only after Postgres is up and the setup Job has finished.

## Prerequisites

### Akeyless secrets

| Path | Keys | Used by |
|---|---|---|
| `/substrate/db` | `POSTGRES_SUPER_PASS`, `SUBSTRATE_OWNER_PASS`, `SUBSTRATE_READWRITE_PASS` | postgres, db-init Job, ate-api-server connection strings |
| `/garage/key` | `GARAGE_KEY_ID`, `GARAGE_KEY_SECRET` | atelet (`substrate-atelet-secret`) |
| `/substrate/service-dns-ca-pool` | CA pool | podcert |
| `/substrate/pod-identity-ca-pool` | CA pool | podcert |
| `/substrate/postgres-ca-pool` | CA pool | podcert (required at startup, even though Postgres uses password auth) |
| `/substrate/actor-id-ca-pool` | CA pool | substrate |
| `/substrate/actor-id-jwt-pool` | JWT signing pool | substrate |
| `/substrate/actor-id-ca-certs` | CA certs | substrate |

### Other requirements

- A Garage bucket reachable at `http://garage.storage.svc.cluster.local:3900`.
- The OCIRepositories `substrate`, `substrate-crds`, `substrate-podcert` and `substrate-atelet` in `k8s/flux/repos/oci/`.

## Database

- **Auth:** ate-api-server connects with passwords (`sslmode=disable`), not client certificates. The connection strings are built in `app/secret.yaml` (`substrate-secret`).
- **Setup:** `substrate-db-init` waits for Postgres and then runs `setup.sql` in a single transaction. It creates the `substrate_owner` and `substrate_readwrite` roles, their login users, and the `substrate` schema. The script is idempotent, so Flux can re-run the Job safely.
- **Keep in sync:** `postgres/config/setup.sql` is vendored from upstream (`pkg/postgressetup/setup.sql`). Update it whenever you bump the substrate chart.
- **Network access:** the chart denies all ingress in `ate-system`. `postgres/network-policy.yaml` allows TCP 5432 from `ate-api-server` and `substrate-db-init` only.
- **Storage:** data lives on a 5Gi `openebs-hostpath` volume on `localstorage-worker1`.

## Reinstalling over an old release

Cluster-scoped leftovers from a previous `substrate` release block the `substrate-atelet` install with a Helm ownership conflict. Delete them first:

```sh
kubectl delete clusterrole atelet-role
kubectl delete clusterrolebinding atelet-binding
```

## Checking the install

```sh
flux get ks -A | grep substrate
kubectl -n ate-system logs job/substrate-db-init
```

## References

- [kagent-dev/substrate](https://github.com/kagent-dev/substrate)
- [Operator install guide](https://github.com/kagent-dev/substrate/blob/main/docs/guides/operator-install.md)
- [Postgres guide](https://github.com/kagent-dev/substrate/blob/main/docs/guides/postgres.md)
- [Authorization guide](https://github.com/kagent-dev/substrate/blob/main/docs/guides/authorization.md)
- [Node storage guide](https://github.com/kagent-dev/substrate/blob/main/docs/guides/node-storage.md)
- [Upgrade guide](https://github.com/kagent-dev/substrate/blob/main/docs/guides/upgrade.md)
- [Upstream `setup.sql`](https://github.com/kagent-dev/substrate/blob/58e4bbcdb/pkg/postgressetup/setup.sql)
- Helm charts: [`substrate`](https://github.com/kagent-dev/substrate/tree/main/charts/substrate), [`substrate-crds`](https://github.com/kagent-dev/substrate/tree/main/charts/substrate-crds), [`substrate-podcert`](https://github.com/kagent-dev/substrate/tree/main/charts/substrate-podcert), [`substrate-atelet`](https://github.com/kagent-dev/substrate/tree/main/charts/substrate-atelet)
