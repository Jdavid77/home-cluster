# NAS Postgres: major version upgrade

How to move the shared Postgres on the NAS (`192.168.1.84:5432`) to a new major version. Most cluster apps keep their databases there. Immich is separate: it uses the vectorchord stack on port 6001, and this runbook doesn't touch it.

**Last run:** 26 November 2026, 18 → 19 (see [History](#history)).

## Overview

With the apps scaled down, the upgrade copies everything with `pg_dumpall` into a new stack running the new major, then swaps the ports. The old stack and its data stay untouched, so rolling back means swapping the ports back.

`pg_upgrade` isn't used, because it needs the old and new Postgres binaries, each with its own PostGIS build, in one image.

The commands below use 18 → 19. For the next upgrade, replace the version numbers. Each command block says where it runs: `NAS` is the NAS, in the Compose Files folder; `Workstation` is your machine, with `kubectl` on the cluster; `This repo` is the root of this repo.

!!! warning
    Paste long commands as separate short lines. When a terminal wraps a long line on paste, it can split a command in the middle, and `psql -c` then runs with no query.

## Prerequisites

Two images of the new major must exist before the cutover: the PostGIS image the new stack on the NAS runs, and the backup image the cluster's backup job runs. The `postgres-init` init containers don't need to change: they only run `psql`, which works against a server of any newer or older major.

1. Build the PostGIS image.

    artifacts-mirror's [`postgis.yaml`](https://github.com/Jdavid77/artifacts-mirror/blob/main/.github/workflows/postgis.yaml) builds `ghcr.io/jdavid77/postgis:<postgres>-<postgis>` for amd64 and arm64, because the upstream image is amd64-only and the NAS is a Raspberry Pi. Add the new major to its `postgres:` matrix, and move `latest` to it. The `<postgres>-<postgis>` pair must exist as a folder in [postgis/docker-postgis](https://github.com/postgis/docker-postgis).

2. Build the backup image.

    `pg_dump` and `pg_dumpall` refuse to dump a server newer than themselves, so the backup job needs a client of the new major before the cutover. [pg-backup-s3](https://github.com/Jdavid77/pg-backup-s3) builds on `postgres:<major>-alpine` and publishes `ghcr.io/jdavid77/pg-backup-s3:pg<major>-<date>`.

Before moving on, check that:

- `ghcr.io/jdavid77/postgis:19-<postgis>` exists for arm64.
- `ghcr.io/jdavid77/pg-backup-s3:pg19-<date>` exists.
- The last `pg-backup-main-garage` job succeeded, so there is a recent backup.

## 1. Scale the apps down

Every app with `postgres` in `DEPENDS_ON` stops, and the rest of the cluster keeps running. In Claude Code, in this repo, run `/postgres-apps down`. Without Claude, run the skill's script directly:

1. List the apps, and check that every app you expect is there.

    ```sh title="This repo"
    .claude/skills/postgres-apps/scripts/postgres-apps.sh list
    ```

2. Scale them down. The script pauses each app's KEDA ScaledObject at zero replicas and waits for the pods to go.

    ```sh title="This repo"
    .claude/skills/postgres-apps/scripts/postgres-apps.sh down
    ```

Before moving on, check that:

- `postgres-apps.sh list` shows every workload at `replicas=0 paused=0`.

## 2. Add the new stack

The new major runs as its own stack next to the old one, on port 5433 while the old server still holds 5432.

1. In [omv-compose](https://github.com/Jdavid77/omv-compose), add `postgres19/postgres19.yml` next to the old stack, with:

    - the image, pinned by digest;
    - host port `5433:5432`;
    - `${APPDATA:?...}/postgres19` mounted at `/var/lib/postgresql`, without setting `PGDATA`.

2. Copy `postgres18.env.example` to `postgres19.env.example`.

3. In the same commit, set the old stack's port to `5434:5432`. Push.

4. On the NAS, pull the change:

    ```sh title="NAS"
    cd /srv/dev-disk-by-uuid-ff763355-7fef-41fe-b2d7-6d368a3b4313/docker/compose
    git pull
    ```

5. Create `postgres19/postgres19.env` with the same `POSTGRES_PASSWORD` as the old stack.

6. In the plugin, select `postgres19`, then **+ → Sync changes from file** and **Up**.

    The plugin only applies a stack's file on **Sync changes from file**, so the old stack stays on 5432 until phase 3.

Before moving on, check that:

- `docker port postgres19` shows `5433`.
- `docker port postgres18` still shows `5432`.

## 3. Move the old server off 5432

On 5434, the old server is out of reach of the apps, so nothing else can write to it during the copy.

1. In the plugin, select `postgres18`, then **Sync changes from file** and **Up**.

Before moving on, check that:

- `docker port postgres18` shows `5434`.

## 4. Copy the data

The dump runs inside the new container, so it uses the new client.

1. Copy everything into the new server. The command reads the password from the new stack's `.env` file, which keeps it out of the shell history.

    ```sh title="NAS"
    docker exec -e PGPASSWORD="$(grep '^POSTGRES_PASSWORD=' postgres19/postgres19.env | cut -d= -f2-)" postgres19 \
      pg_dumpall -h 192.168.1.84 -p 5434 -U postgres \
      | docker exec -i postgres19 psql -U postgres
    ```

    `psql` inside the container connects through the local socket and needs no password. `role "postgres" already exists` is expected.

2. Compare table counts per database. Each line should show the same number twice.

    ```sh title="NAS"
    q="SELECT count(*) FROM information_schema.tables WHERE table_schema NOT IN ('pg_catalog','information_schema')"
    dbs=$(docker exec postgres18 psql -U postgres -Atc "SELECT datname FROM pg_database WHERE NOT datistemplate")
    for db in $dbs; do
      a=$(docker exec postgres18 psql -U postgres -d "$db" -Atc "$q")
      b=$(docker exec postgres19 psql -U postgres -d "$db" -Atc "$q")
      echo "$db: $a vs $b"
    done
    ```

3. Compare the roles (`\du`) and the extensions (`\dx`) on both servers.

4. Check the PostGIS version in the database that uses it:

    ```sh title="NAS"
    docker exec postgres19 psql -U postgres -d adventurelog -c 'SELECT postgis_full_version();'
    ```

Before moving on, check that:

- Every database shows the same table count on both servers.
- The roles and extensions match.
- PostGIS came up at the new version.

If something doesn't match, stop here. The old server still has everything: move it back to 5432 and bring the apps back with `postgres-apps.sh up`.

## 5. Switch over and bring the apps back

The new server takes over 5432, and the apps come back on it.

1. In omv-compose, set the new stack to `5432:5432`. Push.

2. On the NAS, run `git pull`, then in the plugin select `postgres19`, **Sync changes from file** and **Up**.

3. Rebuild the planner statistics, which a dump doesn't carry. `--analyze-in-stages` runs a quick rough pass first, then two finer ones.

    ```sh title="NAS"
    docker exec postgres19 vacuumdb -U postgres --all --analyze-in-stages
    ```

4. Bring the apps back, or run `/postgres-apps up` in Claude Code. The script removes the pause, and KEDA brings each app back to its replica count once the postgres probe is up.

    ```sh title="This repo"
    .claude/skills/postgres-apps/scripts/postgres-apps.sh up
    ```

Before moving on, check that:

- `postgres-apps.sh list` shows every workload back at its replica count, with `paused=-`.
- `kubectl get pods -A --no-headers | awk '$4!="Running" && $4!="Completed"'` prints nothing.
- Gatus is up, and you can log in to Authentik and Vaultwarden.
- `docker logs --since 30m postgres19 2>&1 | grep -E "ERROR|FATAL"` on the NAS prints nothing.

## 6. Switch the backups

The backup job for the `main` server needs the client of the new major.

1. In `k8s/apps/backup/postgres/cron/resourceset.yaml`, set `version` to the new major for the `main` server, under both backends. The image tag is `pg<< $server.version >>-<date>`, and the date is shared by every server, so set it to a date that exists for both majors.

2. Run one backup by hand:

    ```sh title="Workstation"
    kubectl create job -n backup --from=cronjob/pg-backup-main-garage pg-backup-main-garage-manual
    kubectl wait -n backup --for=condition=complete job/pg-backup-main-garage-manual --timeout=5m
    ```

3. Read its log, then delete it:

    ```sh title="Workstation"
    kubectl logs -n backup job/pg-backup-main-garage-manual
    kubectl delete job -n backup pg-backup-main-garage-manual
    ```

Before moving on, check that:

- The job completed, and its log shows the backup uploaded.

## Rollback

Until the old stack is removed, you can go back to the old server. Anything written to the new server since the cutover is lost.

1. In the plugin, select `postgres19` and click **Down**.

2. Set `postgres18` back to `5432:5432`, then **Sync changes from file** and **Up**.

3. Set the backup ResourceSet back to the old major.

Then check that:

- `docker port postgres18` shows `5432`.
- `postgres-apps.sh list` shows every workload at its replica count.

## Cleanup

After about a week without problems, remove the old stack. After that, the backups are the only copy of the old server.

1. Remove the old stack from omv-compose.

2. In the plugin, run **Down** on it.

3. Delete its data folder, `appdata/postgres18`.

Then check that:

- `docker ps -a --filter name=postgres18` on the NAS lists no container.

## History

### 18 → 19, 26 November 2026

- Moved from `ghcr.io/baosystems/postgis:18-3.6` to `ghcr.io/jdavid77/postgis:19-3.7`. baosystems had no stable 19 build.
- The first pg19 build of pg-backup-s3 failed. Alpine only packages `postgresql19-client` in edge/testing, so the image moved to the official `postgres:<major>-alpine` base.
- All app databases matched after the copy. The `postgres` maintenance database lost 34 empty `tiger` tables: the old image had the `postgis_tiger_geocoder` extension and the new one doesn't ship it. Nothing used it.
- The cutover used `OPERATION=suspend task cluster:update`, which only scales down deployments with a Longhorn PVC. Nine of the thirteen apps kept running, and the move to 5434 kept them off the old server. Afterwards, the KEDA `dependencies` component was extended to cover every app on the NAS Postgres, and the `postgres-apps` skill was written to pause it.
- After the cutover, eight leftover databases with no app in the cluster were dropped with their roles: `gotify`, `homebox`, `sonarqube`, `mattermost`, `wallabag`, `watchyourlan`, `tekton-results` and `openshell`. The 26 November Garage backup still has them.
