# NFS: one OMV share for the cluster

The cluster's NFS data lives on the OMV NAS (`192.168.1.84`), spread over 14 shared folders, each exported on its own. This migration moves all of them into subfolders of one shared folder, `k8s`, so the cluster needs a single export.

The apps keep their inline `type: nfs` volumes. Only the `path` changes, from `/photos` to `/k8s/photos`. No new driver is needed.

## Why not csi-driver-nfs

[csi-driver-nfs](https://github.com/kubernetes-csi/csi-driver-nfs) adds a StorageClass that creates a new subfolder for every PVC. That suits new apps that need their own folder, but not this data:

- Most folders are shared between apps (see below). A dynamic PVC belongs to one namespace and gets its own empty folder, so two apps can't share it.
- The data already exists, and a dynamic PVC always starts empty. Reusing a folder would take a hand-written static PV per folder, which is more YAML than the inline `path` and adds nothing.

It can still be added later for new apps, pointing at the same `k8s` share.

## What moves

| Folder | New path | Used by |
|---|---|---|
| `/photos` | `/k8s/photos` | immich, filebrowser |
| `/ebooks` | `/k8s/ebooks` | booklore, filebrowser |
| `/youtube` | `/k8s/youtube` | metube, filebrowser |
| `/confidential` | `/k8s/confidential` | filebrowser |
| `/book-ingests` | `/k8s/book-ingests` | booklore, shelfmark |
| `/downloads` | `/k8s/downloads` | qbittorrent, audiobookshelf |
| `/models` | `/k8s/models` | whisper, llmkube |
| `/pypi` | `/k8s/pypi` | pypiserver |
| `/paperless-data` | `/k8s/paperless-data` | paperless |
| `/paperless-media` | `/k8s/paperless-media` | paperless |
| `/paperless-consume` | `/k8s/paperless-consume` | paperless |
| `/paperless-export` | `/k8s/paperless-export` | paperless |
| `/garage-data` | `/k8s/garage-data` | garage |
| `/garage-meta` | `/k8s/garage-meta` | garage |

The folders keep their names, so only the prefix changes. Nothing in `omv/docker` mounts these folders, so the cluster is their only user.

Every app that uses a folder must move together with it, and filebrowser and booklore each use several folders. The simplest safe order is one maintenance window: stop every app above, copy the last changes, switch every path in one commit and start the apps again.

## What doesn't change

- The `nfs` blackbox probe only checks TCP port 2049 on the NAS, so the KEDA dependency (`DEPENDS_ON: "nfs"`) keeps working.
- zot depends on the `nfs` probe but mounts no NFS volume.

## Before you start

- **Copy, don't move.** The data is copied into `k8s` and the old folders stay untouched until the cleanup, so a rollback only has to point the apps back at them. `mv` would be faster, but then rolling back means moving everything back.
- **Free space.** Until the cleanup, every folder exists twice, so the disk that holds `k8s` needs room for all of it. All the folders are on the same disk, `/srv/dev-disk-by-uuid-ff763355-7fef-41fe-b2d7-6d368a3b4313`, and together they need far less than its free space. Check again with `du -sh` before starting. If there isn't enough room, migrate in batches and clean up each batch before the next.
- **Export options.** Give the new `k8s` NFS share the same client and options as the current shares, so permissions and squashing behave the same.
- **Ownership.** Apps run as specific users (immich runs as `1002:100`). `rsync -aHAX` keeps owners, permissions, hard links, ACLs and extended attributes.

## Steps

### 1. Create the share in OMV

1. **Storage → Shared Folders:** add `k8s` on the chosen disk.
2. **Services → NFS → Shares:** export `k8s` with the same options as the existing shares.
3. Check it from a machine on the network: `showmount -e 192.168.1.84` should list `k8s`.

The old shares stay exported until the cleanup, so the apps can go back to them at any time.

### 2. Change the paths in Git

On a branch, change every `path` in the table above. For example, in `k8s/apps/media/immich/app/helm-release.yaml`:

```yaml
persistence:
  library:
    type: nfs
    server: 192.168.1.84
    path: /k8s/photos
    globalMounts:
      - path: /usr/src/app/upload
```

The files to change:

| File | Paths |
|---|---|
| `k8s/apps/media/immich/app/helm-release.yaml` | `/photos` |
| `k8s/apps/default/filebrowser/app/helm-release.yaml` | `/youtube`, `/ebooks`, `/photos`, `/confidential` |
| `k8s/apps/media/booklore/app/helm-release.yaml` | `/ebooks`, `/book-ingests` |
| `k8s/apps/media/shelfmark/app/helm-release.yaml` | `/book-ingests` |
| `k8s/apps/media/metube/app/helm-release.yaml` | `/youtube` |
| `k8s/apps/media/qbittorrent/app/helm-release.yaml` | `/downloads` |
| `k8s/apps/media/audiobookshelf/app/helm-release.yaml` | `/downloads` |
| `k8s/apps/automation/whisper/app/helm-release.yaml` | `/models` |
| `k8s/apps/automation/llmkube/app/pvc.yaml` | `/models` (in the PersistentVolume) |
| `k8s/apps/development/pypiserver/app/helm-release.yaml` | `/pypi` |
| `k8s/apps/documents/paperless/app/helm-release.yaml` | the four `/paperless-*` paths |
| `k8s/apps/storage/garage/app/helm-release.yaml` | `/garage-data`, `/garage-meta` |

Don't merge yet: the data has to be copied first.

### 3. Copy the data while the apps run

A shared folder's name in OMV can differ from its folder on the disk: the `garage-meta` share is the `garage/meta` folder. List the real folders with:

```sh
omv-confdbadm read conf.system.sharedfolder | jq -r '.[] | "\(.name)\t\(.reldirpath)"'
```

The copy reads from each real folder and writes to `k8s/<share name>`, which matches the new paths in the table. Run as root on the NAS, inside `tmux` so a dropped SSH session doesn't stop it:

```sh
D=/srv/dev-disk-by-uuid-ff763355-7fef-41fe-b2d7-6d368a3b4313
PAIRS="
photos:photos
ebooks:ebooks
youtube:youtube
confidential:confidential
book-ingests:book-ingests
downloads:downloads
models:models
pypi:pypi
paperless-data:paperless/data
paperless-media:paperless/media
paperless-consume:paperless/consume
paperless-export:paperless/export
garage-data:garage/data
garage-meta:garage/meta
"

for p in $PAIRS; do
  name=${p%%:*}; src=${p#*:}
  echo "=== $src -> k8s/$name"
  rsync -aHAX --info=progress2 "$D/$src/" "$D/k8s/$name/"
done
```

The disk also has an empty `paperless-data` folder at its root that no share points at; the real data is in `paperless/data`.

Keep the trailing slashes: they copy the folder's content into the new folder, not the folder into it. This first copy takes as long as the data needs, but nothing is down yet. It doesn't need to be consistent, because step 5 copies again once the apps stop.

### 4. Stop the apps

Suspend each app's Flux Kustomization, so Flux doesn't undo the changes below:

```sh
flux suspend kustomization immich -n media
```

Most of these apps are scaled by the KEDA dependency component, which would start them again. Pause their ScaledObject at zero replicas:

```sh
kubectl annotate scaledobject immich-server -n media autoscaling.keda.sh/paused-replicas="0"
```

The ScaledObject is named after the app's `APP` variable in its `ks.yaml` (`immich-server` for immich, the app name for the others). whisper and llmkube have no ScaledObject: scale whisper with `kubectl scale --replicas=0`, and stop whatever uses the `llmkube-model-cache` PVC.

Wait until no pod in the table still runs, so nothing writes during the final copy.

### 5. Copy the last changes

Run the same loop again, now with `--delete`, with `D` and `PAIRS` set as in step 3:

```sh
for p in $PAIRS; do
  name=${p%%:*}; src=${p#*:}
  echo "=== $src -> k8s/$name"
  rsync -aHAX --delete --info=progress2 "$D/$src/" "$D/k8s/$name/"
done
```

Only files that changed since step 3 are copied, so this takes minutes rather than hours. `--delete` removes files from the copy that the apps deleted in the meantime, so the copy matches the original exactly. It deletes from the second path only, so with the paths swapped it would delete from the original: double-check their order before running it.

To check, run the loop once more with `rsync -aHAX --delete --dry-run --itemize-changes`. It should print only the `===` lines.

### 6. Recreate the llmkube PersistentVolume

A PV's `nfs.path` can't be changed in place, so the PV and its PVC have to be recreated. The PV has `persistentVolumeReclaimPolicy: Retain`, and NFS PVs aren't deleted on the NAS anyway, so this doesn't touch the data:

```sh
kubectl delete pvc llmkube-model-cache -n automation
kubectl delete pv llmkube-model-cache
```

Flux recreates both with the new path when it reconciles in the next step.

### 7. Merge and start the apps

1. Merge the branch.
2. Resume each Kustomization: `flux resume kustomization immich -n media`.
3. Remove the KEDA pause: `kubectl annotate scaledobject immich-server -n media autoscaling.keda.sh/paused-replicas-`.
4. Scale whisper back up if Flux hasn't already.

Check each app:

- The pod is running and its NFS mount shows the data: `kubectl exec -n media deploy/immich-server -- ls /usr/src/app/upload`.
- The app's UI shows its existing data (immich photos, paperless documents, booklore library).
- Garage answers S3 requests, and `garage status` reports no errors.

### 8. Clean up OMV

Once every app has run on the new paths for a while:

1. **Services → NFS → Shares:** remove the old exports.
2. **Storage → Shared Folders:** remove the old shared folders.
3. Delete the old folders on the NAS to free the space, using the real folders from `PAIRS` (for example `paperless/data`, not the empty `paperless-data`). After this, rollback is no longer possible.

## Rollback

Until step 8, the old folders are untouched and still exported, so rolling back only switches the paths back:

1. Stop the apps (step 4).
2. Revert the commit, and recreate the llmkube PV and PVC as in step 6.
3. Start the apps (step 7).

Anything the apps wrote after the switch exists only in `k8s`. To keep it, copy it back with the step 5 command, with the two paths swapped, before starting the apps.
