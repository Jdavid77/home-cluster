#!/bin/bash

K3S_VERSION="v1.27.4+k3s1"
K3S_MASTER_IP="192.168.1.80"
K3S_USER="controlplane"
LOCAL_KUBECONFIG="~/.kube/home-cluster"

SERVER_2_IP="192.168.1.85"
SERVER_2_USER="server2"

SERVER_3_IP="192.168.1.86"
SERVER_3_USER="server3"

k3sup install \
    --ip $K3S_MASTER_IP \
    --user $K3S_USER \
    --k3s-version $K3S_VERSION \
    --k3s-extra-args "--disable servicelb --disable traefik --disable local-storage --disable flannel --disable metrics-server" \
    --cluster \
    --local-path="$LOCAL_KUBECONFIG" \
    --ssh-key "/Users/jnobrega/.ssh/id_rsa"

k3sup join \
    --ip $SERVER_2_IP \
    --user $SERVER_2_USER \
    --server-user $K3S_USER \
    --server-ip $K3S_MASTER_IP \
    --server \
    --k3s-extra-args "--disable servicelb --disable traefik --disable local-storage --disable flannel --disable metrics-server"  

k3sup join \
    --ip $SERVER_3_IP \
    --user $SERVER_3_USER \
    --server-user $K3S_USER \
    --server-ip $K3S_MASTER_IP \
    --server \
    --k3s-extra-args "--disable servicelb --disable traefik --disable local-storage --disable flannel --disable metrics-server"