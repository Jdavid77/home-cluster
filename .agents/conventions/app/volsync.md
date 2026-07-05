# VolSync Conventions

Only add VolSync components if the app needs persistent storage with backup. When you do, also:
- Add `volsync / backup` to `dependsOn` in `ks.yaml`
- Add the components and `postBuild.substitute` block to `ks.yaml`
- Reference `existingClaim: *app` (or the app name) in the HelmRelease persistence section

## Components

Two components, always added together:

```yaml
components:
  - ../../../../components/volsync/local    # Garage S3 (in-cluster)
  - ../../../../components/volsync/remote   # Backblaze B2 (offsite)
```

## `postBuild.substitute` block

Required variables for VolSync to work:

```yaml
postBuild:
  substitute:
    APP: *app
    VOLSYNC_PUID: "1000"   # UID the container runs as
    VOLSYNC_PGID: "1000"   # GID the container runs as
    VOLSYNC_CACHE_CAPACITY: 1Gi  # restic cache size (not PVC size)
```

PUID/PGID must match the UID/GID the container process runs as. Check the image documentation or Dockerfile. When both are the same, use an anchor:

```yaml
VOLSYNC_PGID: &uid "568"
VOLSYNC_PUID: *uid
```

## Persistence in HelmRelease

VolSync creates the PVC via a `ReplicationDestination`. Reference it as an existing claim:

```yaml
persistence:
  config:
    existingClaim: *app        # references the PVC VolSync manages
    globalMounts:
      - path: /data
```
