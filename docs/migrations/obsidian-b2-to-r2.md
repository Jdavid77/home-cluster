# Obsidian vault: Backblaze B2 to Cloudflare R2

**Planned:** 21 November 2026. Not done yet.

The Obsidian vault syncs to the `jnobrega-obsidian` bucket on Backblaze B2 through the Remotely Save plugin. This migration moves the bucket to Cloudflare R2, where the volsync backups already live.

Nothing in the cluster uses this bucket. Its only mention in the repo is `terraform/backblaze/buckets.tf`, so apart from the bucket itself, the migration touches the Remotely Save settings on each device and that one file.

## Decisions

The R2 bucket is created by hand in the Cloudflare dashboard, like the volsync `jnobrega-<app>` buckets. The repo has no Cloudflare Terraform project, and R2 S3 keys are awkward to create from Terraform.

The vault gets its own R2 API token, limited to its bucket. The volsync token in Akeyless (`/r2/key`) stays out of it. This token sits in Remotely Save on every device, so if one device leaks it, only the vault is exposed.

rclone copies the data server to server. Letting Remotely Save upload into an empty bucket would also work, but the copy keeps the objects exactly as they are, Remotely Save encryption included. Remotely Save also never sees an empty remote that it could mistake for deletions.

## Steps

### 1. Create the R2 bucket and token

In the Cloudflare dashboard:

1. Create the bucket `jnobrega-obsidian`. R2 bucket names only need to be unique within the account.
2. Create an R2 API token with the Object Read & Write permission, limited to that bucket. It can also delete objects, which Remotely Save needs to sync deletions. Keep the Access Key ID and Secret Access Key.

### 2. Stop syncing

On every device, turn off auto-sync and sync on save in Remotely Save. Then run one last manual sync from the most up-to-date device. After that nothing writes to B2 during the copy.

### 3. Copy the bucket

Save this script as `obsidian-b2-to-r2.sh` and make it executable. It sets up the two rclone remotes, `backblaze:` and `cloudflare:`, and runs rclone against them. It asks for the B2 and R2 keys when it starts, so they stay out of shell history.

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

If you don't have the bucket's B2 key, Terraform has it:

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

Run "Check connectivity", then a manual sync on one device. The sync should not upload anything again or delete anything. Then do the other devices and turn auto-sync back on.

If a mobile device fails with a CORS error, turn on the plugin's bypass CORS option. The other fix is a CORS rule on the R2 bucket that allows `app://obsidian.md`, `capacitor://localhost` and `http://localhost`.

### 5. Remove the B2 bucket

Once the vault has run on R2 for a while:

1. Check the bucket in the B2 dashboard. The bucket has file lock enabled. If it also has a default retention, B2 keeps locked file versions until the retention expires.
2. Empty the bucket with `./obsidian-b2-to-r2.sh purge`. B2 won't destroy a bucket that still has files.
3. In a PR, remove `jnobrega-obsidian` from `local.buckets` in `terraform/backblaze/buckets.tf`. Atlantis destroys the bucket and its application key.

## Rollback

The B2 bucket stays until step 5. To go back, first copy to B2 anything that changed while the vault was on R2:

```sh
./obsidian-b2-to-r2.sh rollback
```

Then point Remotely Save back at the B2 endpoint, `https://s3.eu-central-003.backblazeb2.com` with region `eu-central-003`, and use the old key.
