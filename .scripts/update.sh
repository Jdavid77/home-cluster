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
    kubectl get scaledobjects -A | awk 'NR>1 {print $1, $2}' | while read ns so; do
        kubectl annotate scaledobject "$so" -n "$ns" \
            autoscaling.keda.sh/paused="true" \
            --overwrite
    done

    echo "==> Scaling down deployments with Longhorn PVCs..."
    kubectl get pvc -A -o custom-columns='NS:.metadata.namespace,NAME:.metadata.name,SC:.spec.storageClassName' \
        | awk '/longhorn/ {print $1, $2}' \
        | while read -r ns pvc; do
            kubectl get deploy -n "$ns" -o json \
                | jq -r --arg pvc "$pvc" \
                    '.items[] | select(.spec.template.spec.volumes[]?.persistentVolumeClaim.claimName == $pvc) | .metadata.name' \
                | while read -r deploy; do
                    kubectl scale deployment "$deploy" -n "$ns" --replicas=0
                done
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
    kubectl get scaledobjects -A | awk 'NR>1 {print $1, $2}' | while read ns so; do
        kubectl annotate scaledobject "$so" -n "$ns" \
            autoscaling.keda.sh/paused- \
            --overwrite
    done

    echo "Done. Flux will restore replicas from git state."
}

case $ACTION in
    suspend) suspend ;;
    resume)  resume ;;
esac
