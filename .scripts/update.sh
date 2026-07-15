#!/bin/bash

set -e

ACTION=$1

suspend() {
    echo "==> Suspending Flux kustomizations..."
    flux get kustomizations -A | awk 'NR>1 {print $1}' | uniq | while read ns; do
        flux suspend kustomization --all -n "$ns"
    done

    echo "==> Suspending Flux helm releases..."
    flux get helmreleases -A | awk 'NR>1 {print $1}' | uniq | while read ns; do
        flux suspend helmrelease --all -n "$ns"
    done

    echo "==> Pausing KEDA scaled objects..."
    k get scaledobjects -A | awk 'NR>1 {print $1, $2}' | while read ns so; do
        k annotate scaledobject "$so" -n "$ns" \
            autoscaling.keda.sh/paused="true" \
            autoscaling.keda.sh/paused-replicas="0" \
            --overwrite
    done

    echo "==> Scaling down all deployments..."
    k get deploy -A | awk 'NR>1 {print $1, $2}' | while read ns deploy; do
        k scale deployment "$deploy" -n "$ns" --replicas=0
    done

    echo "Done. Cluster workloads suspended."
}

resume() {
    echo "==> Resuming Flux kustomizations..."
    flux get kustomizations -A | awk 'NR>1 {print $1}' | uniq | while read ns; do
        flux resume kustomization --all -n "$ns"
    done

    echo "==> Resuming Flux helm releases..."
    flux get helmreleases -A | awk 'NR>1 {print $1}' | uniq | while read ns; do
        flux resume helmrelease --all -n "$ns"
    done

    echo "==> Unpausing KEDA scaled objects..."
    k get scaledobjects -A | awk 'NR>1 {print $1, $2}' | while read ns so; do
        k annotate scaledobject "$so" -n "$ns" \
            autoscaling.keda.sh/paused- \
            autoscaling.keda.sh/paused-replicas- \
            --overwrite
    done

    echo "Done. Flux will restore replicas from git state."
}

case $ACTION in
    suspend) suspend ;;
    resume)  resume ;;
esac