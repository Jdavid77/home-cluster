#!/bin/bash

K3S_VERSION="v1.27.4+k3s1"
K3S_MASTER_IP="192.168.1.80"
K3S_USER="controlplane"
LOCAL_KUBECONFIG="~/.kube/home-cluster"

NEXT_MASTER_IP="192.168.1.85"
NEXT_USER="server2"

k3sup install \
    --ip $K3S_MASTER_IP \
    --user $K3S_USER \
    --k3s-version $K3S_VERSION \
    --k3s-extra-args "--disable servicelb --disable traefik --disable local-storage --disable flannel --disable metrics-server" \
    --cluster \
    --local-path="$LOCAL_KUBECONFIG" \
    --ssh-key "/Users/jnobrega/.ssh/id_rsa"

k3sup join \
    --ip $NEXT_MASTER_IP \
    --user $NEXT_USER \
    --server-user $K3S_USER \
    --server-ip $K3S_MASTER_IP \
    --server \
    --k3s-extra-args "--disable servicelb --disable traefik --disable local-storage --disable flannel --disable metrics-server"  
  
  