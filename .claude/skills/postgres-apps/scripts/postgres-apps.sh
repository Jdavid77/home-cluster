#!/usr/bin/env bash
# Scale down, or back up, every app whose database is on the NAS Postgres,
# by pausing the KEDA ScaledObjects that depend on the postgres probe.
# Usage: postgres-apps.sh list|down|up
set -euo pipefail

PAUSE='autoscaling.keda.sh/paused-replicas'
# Flux's server-side apply drops fields owned by kubectl's own field managers,
# so the pause is written under a manager of its own to survive reconciles.
MANAGER='postgres-apps'

[ "$(kubectl config current-context)" = "admin@home-cluster" ] || {
  echo "kubectl context must be admin@home-cluster" >&2
  exit 1
}

# ScaledObjects whose trigger query names the postgres probe, i.e. apps with
# "postgres" in DEPENDS_ON (k8s/components/keda/dependencies).
# Prints: namespace name targetKind targetName paused-or-"-"
scaledobjects() {
  kubectl get scaledobjects -A -o json | jq -r --arg a "$PAUSE" '.items[]
    | select(any(.spec.triggers[]; (.metadata.query // "") | test("[(|]postgres[)|]")))
    | "\(.metadata.namespace) \(.metadata.name) \(.spec.scaleTargetRef.kind // "Deployment") \(.spec.scaleTargetRef.name) \(.metadata.annotations[$a] // "-")"'
}

list() {
  scaledobjects | while read -r ns so kind target paused; do
    replicas="$(kubectl get -n "$ns" "$kind" "$target" -o jsonpath='{.spec.replicas}')"
    echo "$ns/$so $kind/$target replicas=$replicas paused=$paused"
  done
}

down() {
  scaledobjects | while read -r ns so _ _ _; do
    kubectl annotate -n "$ns" scaledobject "$so" "$PAUSE=0" --overwrite --field-manager="$MANAGER"
  done
  scaledobjects | while read -r ns _ kind target _; do
    kubectl wait -n "$ns" "$kind/$target" --for=jsonpath='{.spec.replicas}'=0 --timeout=2m
    selector="$(kubectl get -n "$ns" "$kind" "$target" -o json \
      | jq -r '.spec.selector.matchLabels | to_entries | map("\(.key)=\(.value)") | join(",")')"
    kubectl wait -n "$ns" --for=delete pod -l "$selector" --timeout=5m
  done
  echo "Done. Every app on the NAS Postgres is scaled down."
}

up() {
  scaledobjects | while read -r ns so _ _ _; do
    kubectl annotate -n "$ns" scaledobject "$so" "$PAUSE-" --field-manager="$MANAGER"
  done
  echo "Done. KEDA is scaling the apps back up once the postgres probe is up."
}

case "${1:-}" in
  list) list ;;
  down) down ;;
  up) up ;;
  *) echo "usage: $0 list|down|up" >&2; exit 2 ;;
esac
