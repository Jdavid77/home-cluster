#!/usr/bin/env bash
kubectl create namespace flux-system
sops -d age-key.sops.yaml | kubectl apply -f -
sops -d github-app.sops.yaml | kubectl apply -f -