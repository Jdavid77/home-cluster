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
- Exit code 1 → report each listed file to the user and explain that it is missing a `# yaml-language-server: $schema=...` comment at the top. Do not auto-fix — warn only.

Native API groups that skip the schema comment check are defined in `.agents/conventions/app/schema-comments.md`. To add a new check, edit `scripts/lint.py`. To bulk-fix ordering violations, run `python3 .claude/skills/lint/scripts/fix_ks_order.py`.
