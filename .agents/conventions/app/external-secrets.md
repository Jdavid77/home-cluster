# External Secrets Conventions

Only add an ExternalSecret if the app actually needs secrets. When you do, also:
- Add `external-secrets-store / external-secrets` to `dependsOn` in `ks.yaml`
- Add a `healthCheckExprs` entry in `ks.yaml` to track secret sync status
- List `secret.yaml` in `app/kustomization.yaml`

## Secret file (`app/secret.yaml`)

```yaml
# yaml-language-server: $schema=https://k8s-schemas-jnobrega.pages.dev/external-secrets.io/externalsecret_v1.json
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: &name my-app-secret
spec:
  refreshInterval: 5m
  secretStoreRef:
    kind: ClusterSecretStore
    name: akeyless-secret-store
  target:
    name: *name
    creationPolicy: Owner
    deletionPolicy: "Delete"
    template:
      engineVersion: v2
      data:
        MY_KEY: "{{ .MY_KEY }}"
  dataFrom:
    - extract:
        key: /my-app/config
```

## Rules

- Secret store is always `ClusterSecretStore / akeyless-secret-store`.
- `refreshInterval: 5m` always.
- `creationPolicy: Owner`, `deletionPolicy: "Delete"` always.
- `engineVersion: v2` always.
- Secret name follows pattern `{app}-secret`; use `&name` anchor.
- Akeyless key paths follow pattern `/{app}/{purpose}` (e.g. `/mealie/db`, `/postgres/super-user`).

## `healthCheckExprs` entry in `ks.yaml`

When an ExternalSecret is present, add this block to `ks.yaml` so Flux tracks sync failures:

```yaml
healthCheckExprs:
  - apiVersion: external-secrets.io/v1
    kind: ExternalSecret
    failed: status.conditions.filter(e, e.type == 'Ready').all(e, e.reason == 'SecretSyncedError')
    current: status.conditions.filter(e, e.type == 'Ready').all(e, e.reason == 'SecretSynced')
```
