#!/usr/bin/env bash

sops -d age-key.sops.yaml | kubectl apply -f -
sops -d github-app.sops.yaml | kubectl apply -f -