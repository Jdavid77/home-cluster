---
name: lint
description: Lint the home-cluster GitOps repository. Checks that CRD YAML files have yaml-language-server schema comments, kustomization resources exist on disk, and every app directory's kustomization lists all sibling files. Use when the user types /lint or asks to lint the repo.
---

# Lint

Run all three checks below and report issues. Do not auto-fix anything — warn only.

## Check 1 — Missing `yaml-language-server` schema comment

Find every `.yaml` file under `k8s/` that:

1. Contains an `apiVersion:` field (i.e. is a Kubernetes manifest, not a config/values file), **and**
2. Is missing a `# yaml-language-server: $schema=...` comment, **and**
3. Has a **non-native** `apiVersion` (custom CRD group)

**Native apiVersions to exclude** (skip files whose `apiVersion:` matches one of these):

- `v1`, `apps/v1`, `batch/v1`, `rbac.authorization.k8s.io/v1`, `networking.k8s.io/v1`, `policy/v1`, `storage.k8s.io/v1`, `admissionregistration.k8s.io/v1`

**How to find them:**

```bash
find k8s/ -name "*.yaml" | while read f; do
  grep -q 'apiVersion:' "$f" || continue          # must have apiVersion
  grep -q '# yaml-language-server' "$f" && continue  # skip if already annotated
  api=$(grep -m1 '^apiVersion:' "$f" | awk '{print $2}')
  case "$api" in
    v1|apps/v1|batch/v1|rbac.authorization.k8s.io/v1|networking.k8s.io/v1|policy/v1|storage.k8s.io/v1|admissionregistration.k8s.io/v1) continue ;;
  esac
  echo "$f"
done
```

**Schema URL pattern** (for reference when user wants to fix manually):
`https://k8s-schemas-jnobrega.pages.dev/<group>/<kind_lowercase>_<version>.json`

Example: `apiVersion: helm.toolkit.fluxcd.io/v2`, `kind: HelmRelease`
→ `https://k8s-schemas-jnobrega.pages.dev/helm.toolkit.fluxcd.io/helmrelease_v2.json`

---

## Check 2 — Kustomization resources exist on disk

For every `kustomization.yaml` under `k8s/apps/`, verify that each path listed under `resources:` and `components:` resolves to a real file or directory relative to the kustomization's own directory.

Report any path that does not exist.

---

## Check 3 — App directories fully listed in kustomization

For every directory under `k8s/apps/` that contains a `kustomization.yaml`, verify that every sibling `.yaml` file (excluding `kustomization.yaml` itself) is listed under `resources:` in that `kustomization.yaml`.

Report any `.yaml` file present in the directory but missing from `resources:`.

---

## Output format

Group findings by check. For each issue print the file path and a one-line description of the problem. Example:

```
[Check 1] k8s/apps/automation/kagent/app/helm-repo.yaml — missing yaml-language-server comment
[Check 2] k8s/apps/monitoring/kustomization.yaml — resources: ./alertmanager/ks.yaml does not exist
[Check 3] k8s/apps/cert-manager/cert-manager/app/kustomization.yaml — grafanadashboard.yaml not listed in resources
```

Print a summary line at the end: `X issues found across Y files.`
