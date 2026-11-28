---
name: migration
description: Write or update a migration record in docs/migrations/ from the work done in this session. Run after a one-off change (moving data, swapping a service, restructuring a repo), or later to record its cleanup.
disable-model-invocation: true
---

# Migration record

A migration record is the history of a one-off change: what changed, why, and exactly how it was done. The rules for the page live in two files, and this skill doesn't repeat them. Read both before writing anything:

- `.agents/conventions/docs/migrations.md`: purpose, page skeleton, cleanup status, Decisions, What was done, Commands
- `.agents/conventions/docs/style.md`: code block titles, admonitions, spacing, the strict build

Use `docs/migrations/nfs-single-share.md` as the model of a finished page.

## Steps

### 1. Check that it's a migration

A migration record is for a change made once. If the work is a procedure that will be repeated (an upgrade done every major version, a routine update), it belongs in a runbook instead: say so, suggest `/runbook`, and wait for the user before writing anything.

Some work is both, like a Postgres major upgrade: the procedure is a runbook, and what went wrong on this particular run is a migration record. Write the record, and tell the user the runbook half exists so they can run `/runbook` for it.

### 2. Find the page

Look in `docs/migrations/` and the **Migrations** nav in `mkdocs.yml` for a page about the same change.

- **No page:** create one. Name the file after the change in kebab-case (`nfs-single-share.md`) and add it to the Migrations nav with a short label.
- **A page exists:** update it (step 4).

### 3. Gather the facts

The record is only worth having if it's accurate, so every fact has to come from somewhere. Look in this order:

1. This session: what was decided and why, the commands as they were actually run, their output, what went wrong.
2. Git and GitHub: `git log`, the PRs and their merge dates (`gh pr view`, `gh pr list`), including PRs in other repos such as omv-compose.
3. Live output already in the session (cluster or NAS). Don't run anything on the NAS; give the user the command instead.

Then list everything still missing, such as a date, the reason for a decision, or what a check printed, and ask the user about all of it in one message. Don't guess and don't leave TODOs. If the user doesn't know, write the sentence without that detail or drop it. A plausible but invented line (a rollback nobody documented, a date) is worse than a gap, because the next reader will trust it.

### 4. Write the page

**New page:** fill the skeleton from the convention, in the past tense. Commands go in as they were run, with real paths and names and no secrets. A one-off script goes in whole. Surprises go in a `!!! note` in the step where they happened.

**Existing page:** change only what the new work affects, following the convention:

- Cleanup done: switch the status line to "Cleaned up on <date>.", rewrite Cleanup in the past tense with the date, and replace Rollback with one line saying it ended with the cleanup.
- A follow-up done: remove it, and record the outcome where it belongs (often What changed).

Leave the rest of the record as it is. It describes what happened then, and later changes don't rewrite it.

### 5. Finish

1. Run the `humanizer` skill in embedded mode on the prose you wrote or changed. Leave code blocks, command output and link targets untouched.
2. Build the docs in strict mode with the repo's MkDocs (install `docs/requirements.txt` in a scratchpad venv if `mkdocs` isn't available):

    ```sh
    mkdocs build --strict -d <scratchpad>/site
    ```

    Then check what style.md asks: every command block titled, no numbered list restarting, the page in the nav.

3. Tell the user which page you created or changed, what you asked them and what you left out, and the build result. Don't commit; the user commits when they've read the page.
