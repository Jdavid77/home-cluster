#!/usr/bin/env bash
# Copies the Terraform state bucket from Backblaze B2 to Cloudflare R2.
# Usage: ./tf-state-b2-to-r2.sh copy|check|list
#   copy   B2 -> R2
#   check  compare B2 and R2
#   list   list the state files on R2
set -euo pipefail

BUCKET=jnobrega-tf-state

case "${1:-}" in
  copy) cmd=(copy backblaze:$BUCKET cloudflare:$BUCKET --progress) ;;
  check) cmd=(check backblaze:$BUCKET cloudflare:$BUCKET) ;;
  list) cmd=(ls cloudflare:$BUCKET) ;;
  *)
    echo "usage: $0 copy|check|list" >&2
    exit 1
    ;;
esac

read -rp "B2 access key ID: " b2_id
read -rsp "B2 secret access key: " b2_secret && echo
read -rp "R2 access key ID: " r2_id
read -rsp "R2 secret access key: " r2_secret && echo

export RCLONE_CONFIG_BACKBLAZE_TYPE=s3
export RCLONE_CONFIG_BACKBLAZE_PROVIDER=Other
export RCLONE_CONFIG_BACKBLAZE_ENDPOINT=https://s3.eu-central-003.backblazeb2.com
export RCLONE_CONFIG_BACKBLAZE_ACCESS_KEY_ID=$b2_id
export RCLONE_CONFIG_BACKBLAZE_SECRET_ACCESS_KEY=$b2_secret

export RCLONE_CONFIG_CLOUDFLARE_TYPE=s3
export RCLONE_CONFIG_CLOUDFLARE_PROVIDER=Cloudflare
export RCLONE_CONFIG_CLOUDFLARE_ENDPOINT=https://015ce648cc705f6d069fe6068434a576.r2.cloudflarestorage.com
export RCLONE_CONFIG_CLOUDFLARE_ACCESS_KEY_ID=$r2_id
export RCLONE_CONFIG_CLOUDFLARE_SECRET_ACCESS_KEY=$r2_secret

rclone "${cmd[@]}"
