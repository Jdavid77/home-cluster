#!/bin/bash

set -e

NODES=("$@")

for node in "${NODES[@]}"; do
    echo "==> Checking etcd status on $node..."
    talosctl etcd status -n "$node"

    echo "==> Defragmenting etcd on $node..."
    talosctl etcd defrag -n "$node"

    echo "==> Post-defrag status on $node..."
    talosctl etcd status -n "$node"

    echo ""
done

echo "Done. etcd defrag complete on all control planes."
