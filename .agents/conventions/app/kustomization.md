# Kustomization (ks.yaml) Conventions

Every app has a `ks.yaml` at `k8s/apps/{namespace}/{app}/ks.yaml`. This file defines the Flux Kustomization that reconciles the app.

## Property order

Canonical order is defined in `ordering.yaml` (key `ks_spec`) and enforced by the lint check.

Properties inside `spec` must follow this order:

```yaml
spec:
  targetNamespace: ...
  dependsOn: ...        # omit if no dependencies
  path: ...
  prune: true
  sourceRef: ...
  healthChecks: ...     # omit if not applicable
  healthCheckExprs: ... # omit if not applicable
  components: ...       # omit if no components
  postBuild: ...        # omit if no substitutions
  wait: true
  interval: 30m
  retryInterval: 2m
  timeout: 15m
```

## Fixed values

These never change across apps:

```yaml
prune: true
wait: true
interval: 30m
retryInterval: 2m
timeout: 15m
```

`timeout` may be shortened for fast-converging system components (e.g. `3m` for operators), but `15m` is the default for all apps.

## Fixed `sourceRef`

Always the same:

```yaml
sourceRef:
  kind: GitRepository
  name: home-cluster
  namespace: flux-system
```

## `&app` anchor

`metadata.name` always defines the `&app` anchor:

```yaml
metadata:
  name: &app my-app
```

Reference it in `postBuild.substitute` as `APP: *app`.

## `dependsOn` rules

Add a `dependsOn` entry for each building block the app uses:

| Building block | Entry to add |
|---|---|
| HTTP route (Envoy) | `- name: envoy` / `namespace: network` |
| ExternalSecret | `- name: external-secrets-store` / `namespace: external-secrets` |
| VolSync backup | `- name: volsync` / `namespace: backup` |

Only add entries for building blocks the app actually uses. No extras.

## `healthChecks`

Add a `healthChecks` entry for each HelmRelease in the app directory:

```yaml
healthChecks:
  - apiVersion: helm.toolkit.fluxcd.io/v2
    kind: HelmRelease
    name: *app
    namespace: <targetNamespace>
```

## `healthCheckExprs`

Add when the app has an ExternalSecret:

```yaml
healthCheckExprs:
  - apiVersion: external-secrets.io/v1
    kind: ExternalSecret
    failed: status.conditions.filter(e, e.type == 'Ready').all(e, e.reason == 'SecretSyncedError')
    current: status.conditions.filter(e, e.type == 'Ready').all(e, e.reason == 'SecretSynced')
```

## `components` and `postBuild`

See `volsync.md` for the full component list and `postBuild.substitute` variables. When VolSync is used, `postBuild` is always present alongside `components`.

## Full skeleton

```yaml
# yaml-language-server: $schema=https://k8s-schemas-jnobrega.pages.dev/kustomize.toolkit.fluxcd.io/kustomization_v1.json
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: &app my-app
spec:
  targetNamespace: default
  dependsOn:
    - name: envoy
      namespace: network
    - name: external-secrets-store
      namespace: external-secrets
  path: ./k8s/apps/default/my-app/app
  prune: true
  sourceRef:
    kind: GitRepository
    name: home-cluster
    namespace: flux-system
  healthChecks:
    - apiVersion: helm.toolkit.fluxcd.io/v2
      kind: HelmRelease
      name: *app
      namespace: default
  healthCheckExprs:
    - apiVersion: external-secrets.io/v1
      kind: ExternalSecret
      failed: status.conditions.filter(e, e.type == 'Ready').all(e, e.reason == 'SecretSyncedError')
      current: status.conditions.filter(e, e.type == 'Ready').all(e, e.reason == 'SecretSynced')
  wait: true
  interval: 30m
  retryInterval: 2m
  timeout: 15m
```
