# NFS: one OMV share for the cluster

**Migrated:** 21 November 2026. The old shares are still in OMV until the [cleanup](#cleanup).

The cluster's NFS data lived on the OMV NAS (`192.168.1.84`), spread over 14 shared folders, each exported on its own. This migration copied all of them into subfolders of one shared folder, `k8s`, so the cluster now uses a single export.

The apps keep their inline `type: nfs` volumes. Only the `path` changed, from `/photos` to `/k8s/photos`, in [#2462](https://github.com/Jdavid77/home-cluster/pull/2462). No new driver was needed.

## What moved

All the folders are on the same disk, `/srv/dev-disk-by-uuid-ff763355-7fef-41fe-b2d7-6d368a3b4313`. A shared folder's name in OMV can differ from its folder on the disk, so the copy read from the real folder and wrote to `k8s/<share name>`:

| Share | Folder on disk | New path | Size | Used by |
|---|---|---|---|---|
| `photos` | `photos/` | `/k8s/photos` | 9.6 GB | immich, filebrowser |
| `ebooks` | `ebooks/` | `/k8s/ebooks` | 1.3 GB | booklore, filebrowser |
| `youtube` | `youtube/` | `/k8s/youtube` | 2.3 GB | metube, filebrowser |
| `confidential` | `confidential/` | `/k8s/confidential` | 0.2 MB | filebrowser |
| `book-ingests` | `book-ingests/` | `/k8s/book-ingests` | empty | booklore, shelfmark |
| `downloads` | `downloads/` | `/k8s/downloads` | 2.1 GB | qbittorrent, audiobookshelf |
| `models` | `models/` | `/k8s/models` | 3.6 GB | whisper, llmkube |
| `pypi` | `pypi/` | `/k8s/pypi` | empty | pypiserver |
| `paperless-data` | `paperless/data/` | `/k8s/paperless-data` | 63 MB | paperless |
| `paperless-media` | `paperless/media/` | `/k8s/paperless-media` | 15 MB | paperless |
| `paperless-consume` | `paperless/consume/` | `/k8s/paperless-consume` | empty | paperless |
| `paperless-export` | `paperless/export/` | `/k8s/paperless-export` | empty | paperless |
| `garage-data` | `garage/data/` | `/k8s/garage-data` | 13.1 GB | garage |
| `garage-meta` | `garage/meta/` | `/k8s/garage-meta` | 0.7 GB | garage |

About 33 GB in total, against 1.8 TB free on the disk. The disk also has an empty `paperless-data` folder at its root that no share points at.

The OMV exports `minio` and `docs` aren't used by the cluster and weren't migrated.

## What didn't change

- The `nfs` blackbox probe only checks TCP port 2049 on the NAS, so the KEDA dependency (`DEPENDS_ON: "nfs"`) kept working.
- zot depends on the `nfs` probe but mounts no NFS volume.

## Decisions

- The data was copied with `rsync`, not moved. The old folders stay untouched until the cleanup, so a rollback only has to point the apps back at them. `mv` would have been instant, but rolling back would mean moving everything back.
- The data was copied twice: first while the apps ran, then a final `rsync --delete` with the apps stopped. Even without uploads, Garage, Paperless, qbittorrent and immich write to their folders on their own, and a copy of Garage's metadata taken while it's written can be inconsistent.
- Everything moved in one maintenance window. filebrowser and booklore each use several folders, so every app stopped and every path changed in one commit.
- The `k8s` export uses the same options as every old export, `192.168.1.0/24(rw,no_subtree_check,insecure)`, so the clients see no difference.


## Steps

The NAS commands ran as root on OMV. The cluster commands ran from a workstation in zsh.

### 1. Create the share in OMV

1. **Storage → Shared Folders:** add `k8s` on the data disk (`ff763355…`).
2. **Services → NFS → Shares:** export `k8s` with `192.168.1.0/24` and `rw,no_subtree_check,insecure`.

Check it:

```sh
D=/srv/dev-disk-by-uuid-ff763355-7fef-41fe-b2d7-6d368a3b4313
ls -ld $D/k8s
grep k8s /etc/exports
```

### 2. Find the real folders

The share names don't always match the folders on the disk (`garage-meta` is `garage/meta`). List them with:

```sh
omv-confdbadm read conf.system.sharedfolder | jq -r '.[] | "\(.name)\t\(.reldirpath)"'
```

That output gives the `share name:folder on disk` pairs that every copy uses:

```sh
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
```

### 3. First copy, with the apps running

```sh
for p in $PAIRS; do
  name=${p%%:*}; src=${p#*:}
  echo "=== $src -> k8s/$name"
  rsync -aHAX --info=progress2 "$D/$src/" "$D/k8s/$name/"
done
```

`-aHAX` keeps owners, permissions, hard links, ACLs and extended attributes; the apps run as specific users. It took about 12 minutes, 5 of them for garage-data.

### 4. Change the paths in Git

[#2462](https://github.com/Jdavid77/home-cluster/pull/2462) changed 20 `path` values in 12 files from `/<share>` to `/k8s/<share>`:

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

The PR stayed a draft until the final copy, since merging it earlier would start the apps on the new paths before the data was there.

### 5. Stop the apps

`APPS` lists the apps that have a KEDA ScaledObject, as `namespace/kustomization:scaledobject`. Each ScaledObject is named after the `APP` variable in the app's `ks.yaml`:

```sh
APPS="
media/immich:immich-server
default/filebrowser:filebrowser
media/booklore:booklore
media/shelfmark:shelfmark
media/metube:metube
media/qbittorrent:qbittorrent
media/audiobookshelf:audiobookshelf
development/pypiserver:pypiserver
documents/paperless:paperless
storage/garage:garage
"
```

!!! note
    The loops use `${=APPS}` because zsh doesn't split an unquoted `$APPS` into words. In bash, use `$APPS`.

Suspend Flux, so it doesn't undo the changes below:

```sh
for a in ${=APPS}; do ns=${a%%/*}; ks=${a#*/}; ks=${ks%%:*}
  flux suspend kustomization "$ks" -n "$ns"; done
for ks in whisper llmkube llmkube-models; do flux suspend kustomization "$ks" -n automation; done
```

Pause KEDA at zero, since it would otherwise start the apps again:

```sh
for a in ${=APPS}; do ns=${a%%/*}; so=${a#*:}
  kubectl annotate scaledobject "$so" -n "$ns" autoscaling.keda.sh/paused-replicas="0" --overwrite; done
```

whisper has no ScaledObject:

```sh
kubectl scale deployment whisper -n automation --replicas=0
```

### 6. Release the llmkube model cache

A PV's `nfs.path` can't be changed in place, so the PV and its PVC had to be recreated. The PV has `persistentVolumeReclaimPolicy: Retain`, so this doesn't touch the data. `llmkube-controller-manager` mounts the PVC, so its pod has to be deleted before the PVC can go:

```sh
kubectl delete pvc llmkube-model-cache -n automation --wait=false
kubectl get pods -n automation -o json \
  | jq -r '.items[] | select(any(.spec.volumes[]?; .persistentVolumeClaim.claimName=="llmkube-model-cache")) | .metadata.name' \
  | xargs -r kubectl delete pod -n automation
kubectl get pvc llmkube-model-cache -n automation   # until NotFound
kubectl delete pv llmkube-model-cache
```

`llmkube-controller-manager` then stays `Pending` until Flux recreates the PVC in step 9.

Check that nothing migrated still runs. Other pods in these namespaces (immich-valkey, dragonfly, garage-ui, zot) don't mount NFS and keep running:

```sh
kubectl get pods -n media; kubectl get pods -n default -l app.kubernetes.io/name=filebrowser
kubectl get pods -n development; kubectl get pods -n documents
kubectl get pods -n storage; kubectl get pods -n automation
```

### 7. Final copy

On the NAS, with `D` and `PAIRS` set as in steps 1 and 2:

```sh
for p in $PAIRS; do name=${p%%:*}; src=${p#*:}; echo "=== $src -> k8s/$name"
  rsync -aHAX --delete --info=progress2 "$D/$src/" "$D/k8s/$name/"; done
```

`--delete` removes files from the copy that the apps deleted since the first copy. It deletes from the second path only, so the order of the two paths matters.

Check that every copy matches its original:

```sh
for p in $PAIRS; do name=${p%%:*}; src=${p#*:}; echo "=== $name"
  rsync -aHAX --delete --dry-run --itemize-changes "$D/$src/" "$D/k8s/$name/"; done
```

It printed only the `===` lines.

### 8. Merge

```sh
gh pr ready 2462 && gh pr merge 2462 --squash
```

### 9. Start the apps

Resume garage first, since volsync depends on it and filebrowser and other apps depend on volsync. The rest resume with `--wait=false`:

```sh
flux reconcile source git home-cluster -n flux-system
flux resume kustomization garage -n storage
for ks in llmkube llmkube-models whisper; do flux resume kustomization "$ks" -n automation --wait=false; done
for a in ${=APPS}; do ns=${a%%/*}; ks=${a#*/}; ks=${ks%%:*}
  flux resume kustomization "$ks" -n "$ns" --wait=false; done
```

Remove the KEDA pause:

```sh
for a in ${=APPS}; do ns=${a%%/*}; so=${a#*:}
  kubectl annotate scaledobject "$so" -n "$ns" autoscaling.keda.sh/paused-replicas-; done
```

Resuming `llmkube` recreated the PV and PVC with `/k8s/models`, and the whisper HelmRelease upgrade brought it back to one replica.

Check that the apps run and mount the new paths:

```sh
kubectl get pods -A | grep -E "immich|filebrowser|booklore|shelfmark|metube|qbittorrent|audiobookshelf|pypiserver|paperless|garage|whisper|llmkube"
kubectl get pv llmkube-model-cache -o jsonpath='{.spec.nfs.path}{"\n"}'
kubectl get pod -n media -l app.kubernetes.io/name=immich -o jsonpath='{.items[*].spec.volumes[?(@.nfs)].nfs.path}{"\n"}'
```

Then check each app's UI for its existing data.

## Cleanup

Not done yet. Once every app has run on the new paths for a while:

1. **Services → NFS → Shares:** remove the 14 old exports.
2. **Storage → Shared Folders:** remove the 14 old shared folders.
3. On the NAS, delete the old folders, using the folders on disk from `PAIRS` (`paperless/data`, not the empty `paperless-data` at the root). After this, rollback is no longer possible.

## Rollback

Until the cleanup, the old folders are untouched and still exported, so rolling back only switches the paths back:

1. Stop the apps (step 5) and release the llmkube model cache (step 6).
2. Revert #2462.
3. Start the apps (step 9).

Anything the apps wrote after the switch exists only in `k8s`. To keep it, copy it back with the step 7 loop, with the two paths swapped, before starting the apps.
