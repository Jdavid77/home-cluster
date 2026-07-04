# App Directory Structure

Every app lives at `k8s/apps/{namespace}/{app}/` and follows a two-level layout.

## Layout

```
k8s/apps/{namespace}/{app}/
├── ks.yaml          # Flux Kustomization — controls reconciliation
└── app/
    ├── kustomization.yaml   # lists all files in this directory
    ├── helm-release.yaml    # HelmRelease
    └── secret.yaml          # ExternalSecret (opt-in)
```

## `ks.yaml` skeleton

The app name is defined once as a YAML anchor `&app` and referenced with `*app` everywhere else.

```yaml
# yaml-language-server: $schema=https://k8s-schemas-jnobrega.pages.dev/kustomize.toolkit.fluxcd.io/kustomization_v1.json
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: &app my-app
spec:
  targetNamespace: default
  path: ./k8s/apps/default/my-app/app
  prune: true
  sourceRef:
    kind: GitRepository
    name: home-cluster
    namespace: flux-system
  healthChecks:
    - apiVersion: helm.toolkit.fluxcd.io/v2
      kind: HelmRelease
      name: my-app
      namespace: default
  wait: true
  interval: 30m
  retryInterval: 2m
  timeout: 15m
```

## `app/kustomization.yaml`

Lists every file in `app/`. Always use the schemastore URL for native Kustomize files.

```yaml
# yaml-language-server: $schema=https://json.schemastore.org/kustomization
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - helm-release.yaml
  - secret.yaml          # only if the app has secrets
```

## Fixed values

| Field | Value |
|---|---|
| `interval` | `30m` |
| `retryInterval` | `2m` |
| `timeout` | `15m` |
| `wait` | `true` |
| `prune` | `true` |
| `sourceRef.kind` | `GitRepository` |
| `sourceRef.name` | `home-cluster` |
| `sourceRef.namespace` | `flux-system` |

## `dependsOn` — when to add each entry

Add a `dependsOn` entry only when the app actually uses that dependency:

| Dependency | When to add |
|---|---|
| `volsync / backup` | app uses VolSync storage components |
| `envoy / network` | app exposes an HTTPRoute |
| `external-secrets-store / external-secrets` | app has an ExternalSecret |
