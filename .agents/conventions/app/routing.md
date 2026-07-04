# Routing Conventions

Apps expose routes via Envoy Gateway using the Gateway API `HTTPRoute`, embedded inline in the HelmRelease `values.route` section. Always add `envoy / network` to `dependsOn` in `ks.yaml` when a route is present.

## Internal vs external

| Gateway | When to use |
|---|---|
| `internal` | App is only accessible on the local network |
| `external` | App needs to be publicly reachable from the internet |

Both gateways live in `namespace: network` and use `sectionName: websecure`.

## Internal route

```yaml
route:
  main:
    parentRefs:
      - kind: Gateway
        name: internal
        namespace: network
        sectionName: websecure
    hostnames:
      - my-app.jnobrega.com
    rules:
      - backendRefs:
          - name: *app
            port: *port
```

## External route

```yaml
route:
  main:
    parentRefs:
      - kind: Gateway
        name: external
        namespace: network
        sectionName: websecure
    hostnames:
      - my-app.jnobrega.com
    rules:
      - backendRefs:
          - name: *app
            port: *port
```

## Hostname format

`{subdomain}.jnobrega.com` — the subdomain is typically the app name or a short descriptive alias (e.g. `food.jnobrega.com` for mealie, `bookmarks.jnobrega.com` for linkding).

## Rules

- `backendRefs.name` always references `*app` anchor.
- `backendRefs.port` always references `*port` anchor.
- One route per app unless the app has multiple distinct frontends.
