#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
K8S_DIR="${REPO_ROOT}/k8s"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

if [[ ! -d "${K8S_DIR}" ]]; then
    log "ERROR: k8s directory not found at ${K8S_DIR}"
    exit 1
fi

log "Starting flux migration across all directories in ${K8S_DIR}"

# Find all directories recursively in k8s and run flux migrate
find "${K8S_DIR}" -type d | while read -r dir; do
    log "Processing directory: ${dir}"
    
    # Change to the directory and run flux migrate
    if cd "${dir}"; then
        if flux migrate -v 2.6 -f .; then
            log "✓ Successfully migrated: ${dir}"
        else
            log "✗ Failed to migrate: ${dir}"
        fi
    else
        log "✗ Failed to change to directory: ${dir}"
    fi
done

log "Flux migration completed"