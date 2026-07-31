# Substrate JWT Auth — Investigation Notes

## Problem

`atenet-router` can't authenticate to `ate-api-server`: JWT verification requires fetching the OIDC discovery doc from the issuer (`https://192.168.1.110:6443`), and that request gets `401`.

## Root cause

- JWT auth mode landed in substrate v0.0.8 (v0.0.7 silently ignored `auth.mode: jwt` and ran mTLS instead).
- For external issuers (our bare-metal VIP isn't `kubernetes.default.svc*`), substrate sends an **unauthenticated** discovery request — by design, OIDC discovery is meant to be public.
- Talos hardcodes `--anonymous-auth=false` on kube-apiserver, so that request gets rejected before RBAC is even checked. The `oidc-discovery-public` ClusterRoleBinding (already applied) is dead weight until anonymous auth is allowed at all.

## Current state

- Substrate pinned to v0.0.10, `auth.mode: jwt`.
- Error 1 (`x509: unknown authority` on discovery, caused by Go not trusting the cluster CA) — **fixed**, via `SSL_CERT_FILE` postRenderers patch on `ate-api-server-deployment` (live, not yet committed).
- Still blocked on the `401` above.

## Fix options

1. **Blanket `anonymous-auth: "true"` in `talos/patches/apiserver.yaml`** — relies on `oidc-discovery-public` RBAC to scope exposure. Simple, works today.
2. **Scope anonymous auth to just the discovery/JWKS paths** via Kubernetes' structured `AuthenticationConfiguration` — tried this, **doesn't work on Talos v1.13.7**: Talos's hardcoded `--anonymous-auth=false` can't be removed/overridden, and it's mutually exclusive with `--authentication-config` regardless of value. Tested live on soyo3-master, confirmed broken, reverted cleanly. Tracked upstream: [siderolabs/talos#11324](https://github.com/siderolabs/talos/issues/11324), fixed via [#13594](https://github.com/siderolabs/talos/pull/13594) as part of Talos v1.14's new multi-doc kube-apiserver config — worth retrying after upgrading.
3. **Switch SA issuer to `kubernetes.default.svc.cluster.local`** — avoids the whole problem, but invalidates all existing SA tokens cluster-wide. Disruptive.

Not yet decided which to take.
