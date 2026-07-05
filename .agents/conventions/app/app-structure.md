# App Directory Structure

Every app lives at `k8s/apps/{namespace}/{app}/` and follows a two-level layout.

## Layout

```
k8s/apps/{namespace}/{app}/
├── ks.yaml          # Flux Kustomization — see kustomization.md
└── app/
    ├── kustomization.yaml   # lists all files in this directory
    ├── helm-release.yaml    # HelmRelease
    └── secret.yaml          # ExternalSecret (opt-in)
```

## `app/kustomization.yaml`

Schema comment rules are defined in `schema-comments.md`.

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - helm-release.yaml
  - secret.yaml          # only if the app has secrets
```
