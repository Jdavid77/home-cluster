---
name: create-app
description: Scaffold a new app in the home-cluster GitOps repo following all conventions. Creates ks.yaml, app/kustomization.yaml, app/helm-release.yaml, and optionally app/secret.yaml. Use when the user asks to add, create, or scaffold a new app or service in the cluster.
---

# Create App

Read `.agents/conventions/app/` before generating any files. Those files are the source of truth for every pattern below.

## Step 1 — Gather required info

Ask the user for anything not already provided. Do not guess — stop and ask.

**Always required:**
- App name (e.g. `mealie`)
- Target namespace (e.g. `default`, `media`, `automation`)
- Container image + tag with digest (`repo/image:tag@sha256:<digest>`)
- Container port

**Ask only if not obvious from context:**
- Does it expose an HTTP route? → internal (LAN only) or external (public)?
- Subdomain for the route (e.g. `food` → `food.jnobrega.com`)
- Does it need secrets? → if yes, what Akeyless key path? (default: `/{app}/config`)
- Does it need persistent storage with backup (VolSync)? → if yes: PUID, PGID, cache capacity
- Does it use postgres? → needed for init container and optionally KEDA component

## Step 2 — Create files

Create all files under `k8s/apps/{namespace}/{app}/`. Follow `.agents/conventions/app/` for every detail: anchors, fixed values, schema comments, dependsOn rules.

**Always create:**
- `ks.yaml` — Flux Kustomization with `&app` anchor, correct `dependsOn` entries, fixed intervals
- `app/kustomization.yaml` — lists all sibling files
- `app/helm-release.yaml` — HelmRelease using `app-template`, `&app`/`*app`/`&port`/`*port` anchors

**Opt-in (only when needed):**
- `app/secret.yaml` — ExternalSecret; also add `healthCheckExprs` to `ks.yaml`
- VolSync components + `postBuild.substitute` block in `ks.yaml`
- KEDA postgres component (only when app uses postgres AND has VolSync)
- Postgres `init-db` initContainer in `helm-release.yaml` (when app uses postgres)

## Step 3 — Self-check before finishing

After generating files, verify:
- [ ] Every YAML manifest has the correct `yaml-language-server` schema comment (see `.agents/conventions/app/schema-comments.md`)
- [ ] `dependsOn` entries match exactly which building blocks are used (no extras)
- [ ] `app/kustomization.yaml` lists every file in `app/`
- [ ] Image tag includes `@sha256:<digest>` (if digest unknown, leave a `# TODO` and tell the user)
- [ ] `&app` anchor is defined in `metadata.name` and referenced with `*app` everywhere else
