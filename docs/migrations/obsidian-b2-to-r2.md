# Obsidian vault: Backblaze B2 to Cloudflare R2

**Planned:** 21 November 2026. Not done yet.

The Obsidian vault syncs to the `jnobrega-obsidian` bucket on Backblaze B2 through the Remotely Save plugin. This migration moves the bucket to Cloudflare R2, where the volsync backups already live.

Nothing in the cluster uses this bucket. It is only declared in `terraform/backblaze/buckets.tf`, so the migration changes the bucket, the Remotely Save settings on each device, and that one Terraform file.

## Decisions

The R2 bucket is created by hand in the Cloudflare dashboard, like the volsync `jnobrega-<app>` buckets. The repo has no Cloudflare Terraform project, and R2 S3 keys are awkward to create from Terraform.

The vault gets its own R2 API token, limited to its bucket, instead of reusing the volsync token in Akeyless (`/r2/key`). The token sits in Remotely Save on every device, so a leaked device key exposes only the vault.

The data is copied server to server with rclone instead of letting Remotely Save upload into an empty bucket. The copy keeps the objects exactly as they are, including Remotely Save encryption, and Remotely Save never sees an empty remote that it could take for deletions.

## Steps

### 1. Create the R2 bucket and token

In the Cloudflare dashboard:

1. Create the bucket `jnobrega-obsidian`. R2 bucket names only need to be unique within the account.
2. Create an R2 API token with **Object Read & Write**, limited to that bucket. Keep the Access Key ID and Secret Access Key.

### 2. Stop syncing

On every device, turn off auto-sync and sync on save in Remotely Save. Run one last manual sync from the most up-to-date device, so nothing writes to B2 during the copy.

### 3. Copy the bucket

Save this script as `obsidian-b2-to-r2.sh` and make it executable. It sets up both rclone remotes (`backblaze:` and `cloudflare:`) and runs the copy. It asks for the B2 and R2 keys when it starts, so they stay out of shell history.

```bash
#!/usr/bin/env bash
# Copies the Obsidian bucket between Backblaze B2 and Cloudflare R2.
# Usage: ./obsidian-b2-to-r2.sh copy|check|rollback|purge
#   copy      B2 -> R2
#   check     compare B2 and R2
#   rollback  R2 -> B2
#   purge     delete everything in the B2 bucket (step 5 only)
set -euo pipefail

BUCKET=jnobrega-obsidian

case "${1:-}" in
  copy) cmd=(copy backblaze:$BUCKET cloudflare:$BUCKET --progress) ;;
  check) cmd=(check backblaze:$BUCKET cloudflare:$BUCKET) ;;
  rollback) cmd=(copy cloudflare:$BUCKET backblaze:$BUCKET --progress) ;;
  purge)
    read -rp "Delete everything in backblaze:$BUCKET? Type the bucket name: " answer
    [[ $answer == "$BUCKET" ]] || { echo "aborted" >&2; exit 1; }
    cmd=(purge backblaze:$BUCKET)
    ;;
  *)
    echo "usage: $0 copy|check|rollback|purge" >&2
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
```

The B2 key for the bucket comes from Terraform if you don't have it:

```sh
cd terraform/backblaze && terraform output -json bucket_credentials
```

Copy, then compare the two buckets:

```sh
./obsidian-b2-to-r2.sh copy
./obsidian-b2-to-r2.sh check
```

`check` should report 0 differences.

### 4. Point Remotely Save at R2

On each device, change the S3 settings in Remotely Save:

| Setting | Value |
|---|---|
| Endpoint | `https://015ce648cc705f6d069fe6068434a576.r2.cloudflarestorage.com` |
| Region | `auto` |
| Bucket | `jnobrega-obsidian` |
| Access Key ID / Secret | the new R2 token |
| Encryption password | unchanged, if one is set |

Run "Check connectivity", then a manual sync on one device. Nothing should be uploaded again or deleted. Then do the other devices and turn auto-sync back on.

If a mobile device fails with a CORS error, turn on the plugin's bypass CORS option, or add a CORS rule to the R2 bucket that allows `app://obsidian.md`, `capacitor://localhost` and `http://localhost`.

### 5. Remove the B2 bucket

Once the vault has run on R2 for a while:

1. Check the bucket in the B2 dashboard. File lock is enabled, so if a default retention is set, locked file versions can't be deleted until it expires.
2. Empty the bucket with `./obsidian-b2-to-r2.sh purge`. B2 won't destroy a bucket that still has files.
3. Remove `jnobrega-obsidian` from `local.buckets` in `terraform/backblaze/buckets.tf` in a PR. Atlantis destroys the bucket and its application key.

## Rollback

Until step 5, the B2 bucket is still there. Point Remotely Save back at the B2 endpoint (`https://s3.eu-central-003.backblazeb2.com`, region `eu-central-003`) with the old key. Copy back first any changes made while on R2:

```sh
./obsidian-b2-to-r2.sh rollback
```
