#!/usr/bin/env bash

kubectl create namespace flux-system
sops -d age-key.sops.yaml | kubectl apply -f -
sops -d github-app.sops.yaml | kubectl apply -f -
kubectl apply -k .

cd ../../flux/vars
sops -d cluster-secrets.sops.yaml | kubectl apply -f -

cd ../config
kubectl apply -k .
