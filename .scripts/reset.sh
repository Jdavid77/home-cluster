#!/usr/bin/env bash
# reset-talos-nodes.sh
# Resets all Talos nodes with --graceful=false --wipe-mode all
# Usage: ./reset-talos-nodes.sh [node1 node2 ...]
# If no args provided, uses the default NODES list below.

set -e

NODES=("$@")
RESET_FLAGS="--graceful=false --wipe-mode all"

echo "======================================"
echo "  Talos Node Reset Script"
echo "======================================"
echo "Nodes to reset: ${NODES[*]}"
echo ""
SUCCESS=()
FAILED=()

for NODE in "${NODES[@]}"; do
  echo "→ Resetting node: ${NODE}"
  # shellcheck disable=SC2086
  if talosctl reset -n "${NODE}" ${RESET_FLAGS}; then
    echo "  ✓ ${NODE} reset successfully"
    SUCCESS+=("${NODE}")
  else
    echo "  ✗ ${NODE} FAILED to reset"
    FAILED+=("${NODE}")
  fi
  echo ""
done

echo "======================================"
echo "  Summary"
echo "======================================"
echo "✓ Succeeded (${#SUCCESS[@]}): ${SUCCESS[*]:-none}"
echo "✗ Failed    (${#FAILED[@]}): ${FAILED[*]:-none}"

if [[ ${#FAILED[@]} -gt 0 ]]; then
  exit 1
fi
