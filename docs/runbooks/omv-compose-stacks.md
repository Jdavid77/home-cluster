# OMV compose stacks: update a stack

How to deploy a change to a Docker Compose stack on the NAS, such as an image update from Renovate. The stacks live in [omv-compose](https://github.com/Jdavid77/omv-compose), and the openmediavault-compose plugin runs them from a git checkout of it. This runbook doesn't cover adding a new stack.

**Last run:** not run from this runbook yet.

## Overview

The plugin's Compose Files shared folder on the NAS is a checkout of omv-compose. A change merged in omv-compose reaches the NAS with a `git pull`, then a sync in the plugin, which only applies a stack's file on **Sync changes from file**. [The migration record](../migrations/omv-compose-repo.md) explains why it's set up this way.

Each command block says where it runs: `NAS` is the NAS, in the Compose Files folder.

## 1. Pull the change

Renovate opens a PR in omv-compose for each image update.

1. Merge the PR in omv-compose.

2. On the NAS, pull the change:

    ```sh title="NAS"
    cd /srv/dev-disk-by-uuid-ff763355-7fef-41fe-b2d7-6d368a3b4313/docker/compose
    git pull
    ```

Before moving on, check that:

- `git pull` finished without errors.

If `git pull` refuses with `Your local changes ... would be overwritten`, a file was edited on the NAS. Check it with `git diff`, then discard it with `git checkout -- <file>` or commit the change to the repo.

## 2. Apply it in the plugin

The plugin keeps its own copy of each stack and applies the file on disk only when told to.

1. In the plugin, select each changed stack, then **+ → Sync changes from file** and **Up**.

Before moving on, check that:

- `docker ps` on the NAS shows the stack's containers running the new image.
