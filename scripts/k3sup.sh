#!/bin/bash

K3S_VERSION="v1.24.7+k3s1"
K3S_SERVER_IP="192.168.1.80"
K3S_USER="server"
LOCAL_KUBECONFIG="~/.kube/home-cluster"
k3sup install --ip $K3S_SERVER_IP --user $K3S_USER --k3s-version $K3S_VERSION --k3s-extra-args "--no-deploy servicelb --no-deploy traefik" --local-path="$LOCAL_KUBECONFIG" --ssh-key "/Users/jnobrega/.ssh/id_ed25519"