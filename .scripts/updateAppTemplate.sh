#!/usr/bin/env bash

set -eou pipefail

if ! command -v kubectl > /dev/null; then
    echo "Kubectl not installed , exiting ..."
    exit 1
fi

if ! command -v flux > /dev/null; then
    echo "Flux CLI not installed , exiting ..."
    exit 1
fi

if ! command -v jq > /dev/null; then
    echo "jq not installed, exiting..."
    exit 1
fi

echo "Finding HelmReleases with 'field is immutable' errors..."
RELEASES=$(kubectl get helmreleases -A -o json | jq -r '.items[] | select(.status.conditions[]? | select(.type == "Ready" and .status == "False" and (.message // "" | contains("field is immutable")))) | "\(.metadata.namespace)/\(.metadata.name)"')

if [[ -z "$RELEASES" ]]; then
    echo "No HelmReleases found with 'field is immutable' errors."
    exit 0
fi

for release in $RELEASES; do

    name=$(echo $release | cut -d "/" -f 2)
    namespace=$(echo $release | cut -d "/" -f 1)

    kubectl delete deployment $name -n $namespace

    while kubectl get pods -n $namespace -l "app.kubernetes.io/name=$name" --no-headers | grep -q .; do
        echo "Waiting for pods to be deleted..."
        sleep 2
    done

    flux suspend helmrelease $name -n $namespace
    sleep 2
    flux resume helmrelease $name -n $namespace

done
