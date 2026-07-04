# Schema Comment Conventions

Every YAML file that contains Kubernetes resources must start with a `# yaml-language-server: $schema=` comment. This enables validation in editors and in the Flux schema plugin.

## URL patterns by file type

### All CRDs (Flux, ExternalSecrets, VolSync, etc.)

Use the custom schema server: `https://k8s-schemas-jnobrega.pages.dev/{Group}/{Kind}_{Version}.json`

- Group: the API group, dot-separated, lowercase (e.g. `kustomize.toolkit.fluxcd.io`)
- Kind: lowercase (e.g. `kustomization`, `helmrelease`, `externalsecret`)
- Version: the API version (e.g. `v1`, `v2`)

Common examples:

```yaml
# yaml-language-server: $schema=https://k8s-schemas-jnobrega.pages.dev/kustomize.toolkit.fluxcd.io/kustomization_v1.json
# yaml-language-server: $schema=https://k8s-schemas-jnobrega.pages.dev/helm.toolkit.fluxcd.io/helmrelease_v2.json
# yaml-language-server: $schema=https://k8s-schemas-jnobrega.pages.dev/external-secrets.io/externalsecret_v1.json
# yaml-language-server: $schema=https://k8s-schemas-jnobrega.pages.dev/volsync.backube/replicationsource_v1alpha1.json
# yaml-language-server: $schema=https://k8s-schemas-jnobrega.pages.dev/volsync.backube/replicationdestination_v1alpha1.json
```

### Native Kustomize files (`kustomization.yaml`, component `kustomization.yaml`)

Use the schemastore URL regardless of whether it is a `Kustomization` or `Component`:

```yaml
# yaml-language-server: $schema=https://json.schemastore.org/kustomization
```

## Placement

The schema comment is always the **first line** of the file, before `apiVersion`.

```yaml
# yaml-language-server: $schema=https://k8s-schemas-jnobrega.pages.dev/helm.toolkit.fluxcd.io/helmrelease_v2.json
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
...
```

## Files that do NOT get schema comments

Files that do not need schema comments:

- `values.yaml`
- `config.yaml`
- `kustomizeconfig.yaml`

Note: `_*.yaml` component template files (e.g. `_local.yaml`) ARE skipped by Flux validation (because `${APP}` substitutions fail regex rules) but **do still get schema comments** for editor support.

## API groups that do NOT get schema comments

Native Kubernetes API types are not served by the custom schema server. Skip the `yaml-language-server` comment for resources with these `apiVersion` values:

- `v1`
- `apps/v1`
- `batch/v1`
- `rbac.authorization.k8s.io/v1`
- `networking.k8s.io/v1`
- `policy/v1`
- `storage.k8s.io/v1`
- `admissionregistration.k8s.io/v1`
- `mirror.plugin.fluxcd.io/v1beta1`
- `apiextensions.k8s.io/v1`
