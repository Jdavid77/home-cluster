---
name: lint
description: Lint the home-cluster GitOps repository. Checks that CRD YAML files have yaml-language-server schema comments, that schema URLs use the correct custom schema server, kustomization resources exist on disk, and every app directory's kustomization lists all sibling files. Use when the user types /lint or asks to lint the repo.
---

# Lint

Rules enforced here are documented in `.agents/conventions/app/schema-comments.md`. Read it for the full rationale, schema URL format, and the list of native API groups that skip schema comments.

Run the checks below and report issues. Do not auto-fix anything — warn only.

## Check 1 — Missing `yaml-language-server` schema comment

Find every `.yaml` file under `k8s/` that:

1. Contains an `apiVersion:` field (i.e. is a Kubernetes manifest, not a config/values file), **and**
2. Is missing a `# yaml-language-server: $schema=...` comment, **and**
3. Has a **non-native** `apiVersion` (custom CRD group)

**How to find them:**

```bash
find k8s/ -name "*.yaml" | while read f; do
  grep -q 'apiVersion:' "$f" || continue          # must have apiVersion
  grep -q '# yaml-language-server' "$f" && continue  # skip if already annotated
  api=$(grep -m1 '^apiVersion:' "$f" | awk '{print $2}')
  case "$api" in
    v1|apps/v1|batch/v1|rbac.authorization.k8s.io/v1|networking.k8s.io/v1|policy/v1|storage.k8s.io/v1|admissionregistration.k8s.io/v1|mirror.plugin.fluxcd.io/v1beta1) continue ;;
  esac
  echo "$f"
done
```
