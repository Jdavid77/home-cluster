# OMV compose stacks: own repo, managed by the plugin

**Migrated:** 24 November 2026. Cleaned up on 24 November 2026.

The NAS runs four Docker Compose stacks: `postgres18`, `vectorchord`, `pihole` and `exit-node`. Their compose files lived in `omv/` in this repo, and Renovate bumped the images there, but nothing deployed those bumps to the NAS. The stacks on the NAS were separate copies managed by hand in the openmediavault-compose plugin.

The stacks now live in their own public repo, [omv-compose](https://github.com/Jdavid77/omv-compose). The plugin's Compose Files shared folder on the NAS is a git checkout of it, so an update is a `git pull` and a sync in the plugin. [Updating the OMV compose stacks](../runbooks/omv-compose-stacks.md) describes how. [#2482](https://github.com/Jdavid77/home-cluster/pull/2482) removed `omv/` from this repo.

## Decisions

- The stacks got their own repo instead of staying in a subfolder or becoming a submodule. The plugin manages one folder of stacks, and checking out this whole repo on the NAS to reach `omv/` would have brought the cluster config with it.
- Each stack is `<name>/<name>.yml`, the layout the plugin expects, so it picks up the stacks without importing them.
- `git subtree split -P omv` carried the 29 commits that touched `omv/` into the new repo, so the history came along.
- Secrets stay on the NAS. Each stack keeps them in `<name>/<name>.env`, which is gitignored and editable in the plugin UI. The plugin creates a `.env` symlink to that file in each stack folder, so every `env_file` is just `./.env`, and `<name>.env.example` lists the keys.
- The stacks mount their data as `${APPDATA:?...}/<app>/...`. `APPDATA` is set in `global.env`, the plugin's global environment file, which is committed at the repo root. The `:?` makes Compose refuse to start a stack if the variable is missing, instead of mounting folders from the root of the disk.

### Why not the plugin's placeholders

The plugin documents two ways to reference shared folders in a compose file: `${{ sf:"appdata" }}` and `CHANGE_TO_COMPOSE_DATA_PATH`. Both were tried and both failed. The plugin only replaces them in files saved from its own editor. Files pulled from git reach Compose unchanged, and Up fails:

```
invalid interpolation format for services.tailscale.volumes.[].
You may need to escape any $ with another $.
${{ sf:"appdata" }}/tailscale:/var/lib/tailscale
```

```
service "tailscale" refers to undefined volume CHANGE_TO_COMPOSE_DATA_PATH/tailscale: invalid compose project
```

The absolute path worked, and was used for a few hours. `APPDATA` replaced it so that the host path is in one place, `global.env`, instead of in every stack.

## What changed

The new repo's layout:

```
omv-compose/
├── global.env                 # APPDATA, committed
├── exit-node/
│   ├── exit-node.yml
│   ├── exit-node.env.example
│   └── Dockerfile             # builds the tailnord image
├── pihole/
├── postgres18/
├── vectorchord/
└── renovate.json
```

`.gitignore` ignores `*.env` except `global.env`, and the `compose.yml` and `compose.override.yml` the plugin generates in each stack folder.

The plugin keeps its own copy of each stack in OMV's database, and its editor shows that copy, not the file on disk. **Sync changes from file**, under the **+** button on the Files tab, reloads the file from disk.

Renovate's default docker-compose pattern doesn't match `<name>.yml`, so `renovate.json` sets `managerFilePatterns` to `/^[^/]+/[^/]+\.yml$/`. Renovate opened its first image update in omv-compose, [omv-compose#2](https://github.com/Jdavid77/omv-compose/pull/2), on 25 November 2026.

## What was done

### 1. Created the repo

From this repo, `omv/` was split with its history and pushed to the new repo:

```sh title="This repo"
git subtree split -P omv -b omv-split
git push git@github.com:Jdavid77/omv-compose.git omv-split:main
```

Then, in omv-compose, each stack moved to `<name>/<name>.yml`, the volumes were pointed at `${APPDATA:?...}`, every `env_file` was set to `./.env`, and `global.env`, `.gitignore` and `renovate.json` were added.

### 2. Checked out the repo on the NAS

The Compose Files folder had no `.git`. Turning it into a checkout of omv-compose kept the existing `<name>.env` files, because they're gitignored:

```sh title="NAS"
cd /srv/dev-disk-by-uuid-ff763355-7fef-41fe-b2d7-6d368a3b4313/docker/compose
git init
git remote add origin https://github.com/Jdavid77/omv-compose.git
git fetch origin
git checkout -f -B main origin/main
```

!!! note
    The folder is owned by root, so git refused it with `detected dubious ownership`. The plugin runs its own git commands too, and a `--global` exception in root's config didn't help it. A system-wide exception covers every user:

    ```sh title="NAS"
    sudo git config --system --add safe.directory /srv/dev-disk-by-uuid-ff763355-7fef-41fe-b2d7-6d368a3b4313/docker/compose
    ```

The plugin's **Init git repo** wasn't needed, and it warns that it erases history.

### 3. Synced and started the stacks

In the plugin, each stack was selected in this order: postgres18, vectorchord, pihole, exit-node. For each, **+ → Sync changes from file**, then **Up**. exit-node built the `tailnord` image on its first Up.

### 4. Checked the mounts

```sh title="NAS"
docker ps -q | xargs docker inspect --format '{{.Name}}: {{range .Mounts}}{{.Source}} {{end}}' | grep appdata
```

All five containers (postgres18, immich_postgres, pihole, tailnord-nordvpn, tailnord-tailscale) mounted from `/srv/dev-disk-by-uuid-ff763355-7fef-41fe-b2d7-6d368a3b4313/docker/appdata/`. The two Postgres containers also showed an anonymous `/var/lib/docker/volumes/<hash>/_data` volume. The Postgres image declares a `VOLUME` on the parent of the data path, and the data still goes to the bind mount.

## Cleanup

[#2482](https://github.com/Jdavid77/home-cluster/pull/2482), merged on 24 November 2026, deleted `omv/` and its `.gitignore` line, and pointed the README, `CLAUDE.md`, `AGENTS.md` and the repo structure notes at omv-compose.
