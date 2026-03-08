#!/usr/bin/env bash
# reset-talos-nodes.sh
# Resets all Talos nodes with --graceful=false --wipe-mode all
# Usage: ./reset-talos-nodes.sh [node1 node2 ...]
# If no args provided, uses the default NODES list below.

set -euo pipefail

# ── Configuration ─────────────────────────────────────────────
NODES=(
  192.169.1.101
  192.168.1.91
  192.168.1.92
  192.168.1.93
  192.168.1.83
  192.168.1.82
  192.168.1.81
)

RESET_FLAGS="--graceful=false --wipe-mode all"
# ──────────────────────────────────────────────────────────────

# Allow nodes to be passed as CLI args
if [[ $# -gt 0 ]]; then
  NODES=("$@")
fi

echo "======================================"
echo "  Talos Node Reset Script"
echo "======================================"
echo "Nodes to reset: ${NODES[*]}"
echo "Flags: ${RESET_FLAGS}"
echo ""
read -rp "⚠️  This will WIPE all nodes. Are you sure? (yes/no): " CONFIRM

if [[ "${CONFIRM}" != "yes" ]]; then
  echo "Aborted."
  exit 0
fi

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