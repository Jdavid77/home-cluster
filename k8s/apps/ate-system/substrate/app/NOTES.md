# Substrate JWT Auth — Investigation Notes

## Problem

`atenet-router` spams a gRPC health check failure every second:

```
ATE API gRPC health check failed: rpc error: code = Unauthenticated
desc = invalid bearer token: while discovering keys from issuer: ...
```

`atenet-router` sends its projected SA token to `ate-api-server` for authentication. `ate-api-server` must verify the JWT by fetching the OIDC discovery document from the token issuer (`https://192.168.1.110:6443`).

---

## Root Cause Chain

### Why it broke at v0.0.8 (worked at v0.0.7)

JWT auth mode was introduced in **v0.0.8** via commit `3400f7fb feat: add jwt authentication mode for ateapi (#248)`. At v0.0.7 the binary didn't implement JWT — `auth.mode: jwt` in Helm values was silently ignored. The chart templates are byte-for-byte identical between versions; the regression is purely in the binary.

### Error 1: `x509: certificate signed by unknown authority` (v0.0.7→v0.0.8)

`ate-api-server` uses Go's system CA pool (public Mozilla bundle in distroless image) for OIDC discovery, not the cluster CA. Despite `--client-jwt-ca-cert` being passed, substrate doesn't apply it to the OIDC HTTP transport.

**Fix applied (`86ccd565`):** injected `SSL_CERT_FILE=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt` via postRenderers patch on `ate-api-server-deployment`. Go reads this globally and adds the cluster CA to the trust pool.

### Error 2: `non-200 response code 401`

After the TLS fix, OIDC discovery returns 401. Substrate's `buildK8sServiceAccountIssuerDiscoveryClient` takes two paths:

```go
func isInClusterKubernetesIssuer(issuer string) bool {
    // true only for kubernetes.default.svc or kubernetes.default.svc.cluster.local
}

func buildK8sServiceAccountIssuerDiscoveryClient(...) *http.Client {
    if !isInClusterKubernetesIssuer(issuer) {
        return &http.Client{Timeout: 10 * time.Second}  // no Bearer token, no custom CA
    }
    // Bearer token injection only for kubernetes.default.svc* issuers
}
```

The issuer is `https://192.168.1.110:6443` (bare-metal VIP). Substrate classifies this as an "external issuer" and uses a plain unauthenticated HTTP client — by design, OIDC discovery is meant to be public. But Talos ships with `--anonymous-auth=false` (CIS hardening default), so the unauthenticated request is rejected before RBAC is even consulted.

There is no env var or flag to make substrate inject a Bearer token for non-`kubernetes.default.svc` issuers.

### Why `oidc-discovery-public` ClusterRoleBinding doesn't help

The binding grants `system:unauthenticated` access to the OIDC discovery endpoints. However, with `--anonymous-auth=false`, anonymous requests are rejected at the authentication layer before RBAC is consulted. The binding only works when anonymous auth is enabled.

---

## Resolution: Rolled back to v0.0.7

Since the root cause is the JWT auth binary introduced in v0.0.8, and enabling `anonymous-auth: "true"` in Talos was deferred, substrate was pinned back to **v0.0.7** in `k8s/flux/repos/oci/substrate.yaml`. At v0.0.7 the binary ignores `auth.mode: jwt` and falls back to mTLS, which requires no OIDC discovery.

---

## If upgrading beyond v0.0.7 in the future

The 401 blocker requires one of:

1. **Enable `anonymous-auth: "true"` in Talos** (`talos/patches/apiserver.yaml`) and rely on the `oidc-discovery-public` ClusterRoleBinding to limit exposure to only `/.well-known/openid-configuration` and `/openid/v1/jwks`. No node reboot required — kube-apiserver pod restarts automatically. This is the correct long-term fix; OIDC discovery endpoints are designed to be public.

2. **Switch issuer to `https://kubernetes.default.svc.cluster.local`** in Talos `--service-account-issuer`. Substrate would then take the authenticated in-cluster path. Disruptive: invalidates all existing SA tokens.

After fixing the 401, a potential follow-up: the OIDC discovery document may return `jwks_uri` pointing at a specific master node IP (`192.168.1.81`) instead of the VIP (`192.168.1.110`). If that node is unreachable, add `service-account-jwks-uri: https://192.168.1.110:6443/openid/v1/jwks` to the Talos apiserver extraArgs.
