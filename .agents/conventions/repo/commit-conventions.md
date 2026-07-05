# Commit Conventions

This repo follows [Conventional Commits](https://www.conventionalcommits.org/).

## Format

```
<type>(<scope>): <subject>
```

`scope` is optional. Subject is lowercase, imperative mood, no trailing period.

## Types

| Type | Use for |
|---|---|
| `feat` | New feature or capability |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `chore` | Maintenance, tooling, deps |
| `ci` | CI/CD pipeline changes |
| `style` | Formatting, linting — no logic change |
| `refactor` | Code restructure, no behavior change |

## Scope

Use the app name when the change is scoped to a single app:

```
feat(plex): add transcoding config
fix(grafana): correct dashboard uid
```

Omit scope for cross-cutting changes:

```
feat: add schema validation on PRs
chore: update kagent
```

> Renovate uses `container` and `deps` as scopes automatically — don't replicate these manually.

## Examples

```
feat(immich): enable machine learning
fix(n8n): correct postgres connection string
docs: update kustomization conventions
chore: bump flux to v2.5
ci: add yaml lint check
style: fix ks.yaml property order
refactor: consolidate volsync components
```
