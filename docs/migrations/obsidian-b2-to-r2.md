# Obsidian vault: Backblaze B2 to Cloudflare R2

**Migrated:** 21 November 2026. The B2 bucket is deleted; see [cleanup](#cleanup).

The Obsidian vault syncs through the Remotely Save plugin. It used the `jnobrega-obsidian` bucket on Backblaze B2 and now uses a bucket of the same name on Cloudflare R2, where the volsync backups already live.

Nothing in the cluster used this bucket. Its only mention in the repo was `terraform/backblaze/buckets.tf`, so apart from the bucket itself, the migration touched the Remotely Save settings on each device.

## Decisions

The R2 bucket was created by hand in the Cloudflare dashboard, like the volsync `jnobrega-<app>` buckets. The repo has no Cloudflare Terraform project, and R2 S3 keys are awkward to create from Terraform.

The vault has its own R2 API token, limited to its bucket. The volsync token in Akeyless (`/r2/key`) stays out of it. This token sits in Remotely Save on every device, so if one device leaks it, only the vault is exposed.

rclone copied the data server to server. Letting Remotely Save upload into an empty bucket would also have worked, but the copy kept the objects exactly as they were, Remotely Save encryption included. Remotely Save also never saw an empty remote that it could mistake for deletions.

## What was done

### 1. Created the R2 bucket and token

In the Cloudflare dashboard:

1. Created the bucket `jnobrega-obsidian`. R2 bucket names only need to be unique within the account.
2. Created an R2 API token with the Object Read & Write permission, limited to that bucket. It can also delete objects, which Remotely Save needs to sync deletions.

### 2. Stopped syncing

On every device, auto-sync and sync on save were turned off in Remotely Save, after one last manual sync from the most up-to-date device. Nothing wrote to B2 during the copy.

### 3. Copied the bucket

This script sets up the two rclone remotes, `backblaze:` and `cloudflare:`, and runs rclone against them. It asks for the B2 and R2 keys when it starts, so they stay out of shell history.

```bash
#!/usr/bin/env bash
# Copies the Obsidian bucket between Backblaze B2 and Cloudflare R2.
# Usage: ./obsidian-b2-to-r2.sh copy|check
#   copy   B2 -> R2
#   check  compare B2 and R2
set -euo pipefail

BUCKET=jnobrega-obsidian

case "${1:-}" in
  copy) cmd=(copy backblaze:$BUCKET cloudflare:$BUCKET --progress) ;;
  check) cmd=(check backblaze:$BUCKET cloudflare:$BUCKET) ;;
  *)
    echo "usage: $0 copy|check" >&2
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

The bucket's B2 key came from the `bucket_credentials` output of the old `backblaze` Terraform project.

The copy ran with `./obsidian-b2-to-r2.sh copy`, then `./obsidian-b2-to-r2.sh check` compared the two buckets.

### 4. Pointed Remotely Save at R2

Each device now has these S3 settings in Remotely Save:

| Setting | Value |
|---|---|
| Endpoint | `https://015ce648cc705f6d069fe6068434a576.r2.cloudflarestorage.com` |
| Region | `auto` |
| Bucket | `jnobrega-obsidian` |
| Access Key ID / Secret | the R2 token |
| Encryption password | unchanged, if one is set |

After "Check connectivity" and a manual sync on one device, the other devices followed and auto-sync went back on.

If a mobile device fails with a CORS error, turn on the plugin's bypass CORS option. The other fix is a CORS rule on the R2 bucket that allows `app://obsidian.md`, `capacitor://localhost` and `http://localhost`.

## Cleanup

The vault's B2 bucket went away with the rest of the B2 account. By then everything else had moved to R2 too: volsync, the Postgres backups and the Terraform state ([#2464](https://github.com/Jdavid77/home-cluster/pull/2464)). A one-off script with the `b2` CLI emptied and deleted every bucket except the snapshot bucket, which B2 only lets you delete from its Snapshots page. [#2465](https://github.com/Jdavid77/home-cluster/pull/2465) then removed the `backblaze` Terraform project.
