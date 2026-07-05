# HelmRelease Conventions

All apps use the `app-template` chart deployed as an OCIRepository from `flux-system`.

## Skeleton

```yaml
# yaml-language-server: $schema=https://k8s-schemas-jnobrega.pages.dev/helm.toolkit.fluxcd.io/helmrelease_v2.json
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: &app my-app
spec:
  interval: 15m
  timeout: 5m
  chartRef:
    kind: OCIRepository
    name: app-template
    namespace: flux-system
  maxHistory: 2
  values:
    controllers:
      my-app:
        annotations:
          reloader.stakater.com/auto: "true"
        containers:
          app:
            image:
              repository: ghcr.io/example/my-app
              tag: 1.0.0@sha256:<digest>
            resources:
              requests:
                cpu: 10m
                memory: 128Mi
    service:
      app:
        controller: *app
        ports:
          http:
            port: &port 8080
    # route — see routing.md for the full route block
```

## Ordering

Canonical key order is defined in `ordering.yaml` (keys `hr_values`, `hr_controller`, `hr_container`) and enforced by the lint check.

**Top-level `values:` keys** (optional keys omitted when not needed):

```
defaultPodOptions → controllers → service → route → persistence → serviceAccount → rbac
```

**Inside `controllers.<name>:`**

```
replicas → strategy → annotations → initContainers → containers → pod
```

**Inside `containers.<name>:`**

```
image → env → envFrom → probes → securityContext → resources
```

## Rules

- `metadata.name` always uses `&app` anchor; reference with `*app` in `service.app.controller`, `healthChecks`, and `backendRefs`.
- `maxHistory: 2` always.
- `interval: 15m`, `timeout: 5m` always.
- Controller name matches the app name (same as `metadata.name`).
- Always add `reloader.stakater.com/auto: "true"` annotation on the controller.
- Image tag must include the digest pinned with `@sha256:<digest>`.
- Port defined as `&port <number>` anchor; referenced with `*port` in `backendRefs`.

## Probes

Add liveness/readiness probes when the app exposes a health endpoint. Use an anchor to avoid duplication:

```yaml
probes:
  liveness: &probes
    enabled: true
    custom: true
    spec:
      httpGet:
        path: /health
        port: *port
      initialDelaySeconds: 0
      periodSeconds: 10
      timeoutSeconds: 1
      failureThreshold: 3
  readiness: *probes
  startup:
    enabled: false
```

## Postgres init container

When the app needs postgres, add an `init-db` initContainer and an `envFrom` anchor shared with the main container:

```yaml
initContainers:
  init-db:
    image:
      repository: ghcr.io/home-operations/postgres-init
      tag: 18.4@sha256:<digest>
    envFrom: &envFrom
      - secretRef:
          name: my-app-secret
containers:
  app:
    envFrom: *envFrom
```
