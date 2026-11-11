# Agent Substrate

[Agent Substrate](https://github.com/kagent-dev/substrate) running in `ate-system`. It is installed as five Flux Kustomizations, all defined in `ks.yaml`. `substrate-podcert` deploys into its own namespace, `podcertificate-controller-system`.

kagent (`k8s/apps/automation/kagent`) is the only consumer: it runs its agents on Substrate and shares Substrate's database.

## Layout

| Directory | Kustomization | What it deploys |
|---|---|---|
| `crds/` | `substrate-crds` | Substrate CRDs |
| `podcert/` | `substrate-podcert` | podcert controller, its CA pools (`service-dns`, `pod-identity`, `postgres`) and its own namespace, all in `podcertificate-controller-system` |
| `db/` | `substrate-db` | `db-init` Job: creates the shared `kagent` database on the NAS if missing and provisions the `substrate` and `kagent` schemas |
| `atelet/` | `substrate-atelet` | atelet DaemonSet, which stores snapshots in Garage over S3 |
| `app/` | `substrate` | ate-api-server, controller, IdP, router, egress, and the actor-id CA pools |

## Install order

```
substrate-crds ─────┬─> substrate-atelet ─┐
substrate-podcert ──┘                     ├─> substrate ──> kagent (automation)
substrate-db ─────────────────────────────┘
```

`substrate` installs only after the setup Job has finished. kagent waits for both `substrate` and `substrate-db`, since its schema is created by the same Job.

## Prerequisites

### Akeyless secrets

| Path | Keys | Used by |
|---|---|---|
| `/postgres/super-user` | `POSTGRES_SUPER_USER`, `POSTGRES_SUPER_PASS` | db-init Job (superuser of the NAS Postgres; creates the database and roles) |
| `/substrate/db` | `SUBSTRATE_OWNER_PASS`, `SUBSTRATE_READWRITE_PASS` | db-init Job, ate-api-server connection strings |
| `/kagent/db` | `KAGENT_OWNER_PASS`, `KAGENT_READWRITE_PASS` | db-init Job, kagent connection strings |
| `/garage/key` | `GARAGE_KEY_ID`, `GARAGE_KEY_SECRET` | atelet (`substrate-atelet-secret`) |
| `/substrate/service-dns-ca-pool` | CA pool | podcert |
| `/substrate/pod-identity-ca-pool` | CA pool | podcert |
| `/substrate/postgres-ca-pool` | CA pool | podcert (required at startup, even though Postgres uses password auth) |
| `/substrate/actor-id-ca-pool` | CA pool | substrate |
| `/substrate/actor-id-jwt-pool` | JWT signing pool | substrate |
| `/substrate/actor-id-ca-certs` | CA certs | substrate |
| `/substrate/egress-mitm-ca-pool` | `pool`, `tls.crt`, `tls.key` | atenet-egress (HTTPS interception) |

Secret rotation is not automated yet.

### Other requirements

- The NAS Postgres (postgres18) at `192.168.1.84:5432`.
- A Garage bucket reachable at `http://garage.storage.svc.cluster.local:3900`.
- The OCIRepositories `substrate`, `substrate-crds`, `substrate-podcert` and `substrate-atelet` in `k8s/flux/repos/oci/`.
- Outbound access to `raw.githubusercontent.com`: `db/kustomization.yaml` fetches the setup scripts on every reconcile.

## Database

- **Where:** the NAS Postgres at `192.168.1.84:5432`. kagent and substrate share the `kagent` database in separate schemas (`kagent` and `substrate`), as in the upstream install guide.
- **Auth:** both apps connect with passwords (`sslmode=disable`), not client certificates. Substrate's connection strings are built in `app/secret.yaml` (`substrate-secret`); kagent's in `k8s/apps/automation/kagent/app/secret.yaml` (`kagent-postgres-owner`, `kagent-postgres-readwrite`).
- **Setup:** `db-init` connects as the superuser, creates the `kagent` database if missing, then runs substrate's and kagent's upstream `setup.sql`, each in a single transaction. They create the `substrate_*` and `kagent_*` owner/read-write roles, their login users, and the `substrate` and `kagent` schemas. Both scripts are idempotent, so Flux can re-run the Job safely.
- **Keep in sync:** `db/kustomization.yaml` pulls both `setup.sql` files straight from upstream at pinned tags. Bump them whenever you bump the substrate or kagent chart.

## kagent integration

Settings in `app/helm-release.yaml` and elsewhere that exist only for kagent:

- `ateApi.authorization.bootstrapOwners` includes `spiffe://cluster.local/ns/automation/sa/kagent-controller`. Without it, agents fail with `RuntimePreparationFailed (PermissionDenied)`.
- `atenetRouter.ingressAllowedSPIFFEIDs` admits the same identity, so the controller can reach agents through the router.
- `credentialProvider.namespacePolicies` lets the `automation` atespace read Secrets in `automation`. The provider denies everything by default.
- The `automation` namespace carries `ate.dev/api-access: "true"`. The chart's NetworkPolicies deny all ingress in `ate-system` except from labelled namespaces; without the label kagent-controller times out (`context deadline exceeded`).
- `preview: [PerTemplateSnapshotLocation, GoldenEgressPolicy]` must match between `substrate` and `substrate-atelet`.

## Reinstalling over an old release

Cluster-scoped leftovers from a previous release block a fresh install with a Helm ownership conflict. This happens for `substrate-atelet`, and for `substrate-podcert` whenever its release moves namespace. Delete the leftovers and let Flux retry:

```sh
kubectl delete clusterrole atelet-role
kubectl delete clusterrolebinding atelet-binding
```

## Checking the install

```sh
flux get ks -A | grep -E 'substrate|kagent'
kubectl -n ate-system logs job/db-init
kubectl get pods -n ate-system
kubectl get pods -n podcertificate-controller-system
```

## References

- [kagent-dev/substrate](https://github.com/kagent-dev/substrate)
- [kagent installation guide](https://kagent.dev/docs/kagent/latest/setup/installation/)
- [Operator install guide](https://github.com/kagent-dev/substrate/blob/main/docs/guides/operator-install.md)
- [Postgres guide](https://github.com/kagent-dev/substrate/blob/main/docs/guides/postgres.md)
- [Authorization guide](https://github.com/kagent-dev/substrate/blob/main/docs/guides/authorization.md)
- [Node storage guide](https://github.com/kagent-dev/substrate/blob/main/docs/guides/node-storage.md)
- [Upgrade guide](https://github.com/kagent-dev/substrate/blob/main/docs/guides/upgrade.md)
- Setup scripts: [substrate `setup.sql` @ v1.0.1](https://github.com/kagent-dev/substrate/blob/v1.0.1/pkg/postgressetup/setup.sql), [kagent `setup.sql` @ v1.0.0](https://github.com/kagent-dev/kagent/blob/v1.0.0/go/core/pkg/postgressetup/setup.sql)
- Helm charts: [`substrate`](https://github.com/kagent-dev/substrate/tree/main/charts/substrate), [`substrate-crds`](https://github.com/kagent-dev/substrate/tree/main/charts/substrate-crds), [`substrate-podcert`](https://github.com/kagent-dev/substrate/tree/main/charts/substrate-podcert), [`substrate-atelet`](https://github.com/kagent-dev/substrate/tree/main/charts/substrate-atelet)
