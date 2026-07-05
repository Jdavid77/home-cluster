---
name: lint
description: Lint the home-cluster GitOps repository. Checks that CRD YAML files have yaml-language-server schema comments. Use when the user types /lint or asks to lint the repo.
---

# Lint

Run the lint script and report its output verbatim:

```bash
python3 .claude/skills/lint/scripts/lint.py
```

- Exit code 0 → all checks passed, tell the user.
- Exit code 1 → report each violation. Do not auto-fix — warn only.

| # | Check | Convention | Fix |
|---|---|---|---|
| 1 | Schema comments on CRD YAML files | `schema-comments.md` | — |
| 2 | `ks.yaml` spec property order | `ordering.yaml` → `ks_spec` | `fixes/ks_order.py` |
| 3 | `helm-release.yaml` values order (app-template only) | `ordering.yaml` → `hr_values/hr_controller/hr_container` | `fixes/hr_order.py` |

New check: add a module under `scripts/checks/`, import in `scripts/lint.py`. New fix: add a script under `scripts/fixes/`.
