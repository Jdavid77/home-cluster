#!/usr/bin/env bash

kubectl create namespace flux-system
sops -d age-key.yaml | kubectl apply -f -
sops -d github-deploy-key.yaml | kubectl apply -f -
kubectl apply -k .