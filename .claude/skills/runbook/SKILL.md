---
name: runbook
description: Write or update a runbook in docs/runbooks/ from a procedure done in this session. Run after doing a repeatable procedure for the first time, or after running an existing runbook to record the run and fix any step that didn't match.
disable-model-invocation: true
---

# Runbook

A runbook is a procedure you'll repeat, written so the next run can follow it step by step. The rules for the page live in two files, and this skill doesn't repeat them. Read both before writing anything:

- `.agents/conventions/docs/runbooks.md`: purpose, page skeleton, steps and checks, Last run
- `.agents/conventions/docs/style.md`: code block titles, admonitions, spacing, the strict build

Use `docs/runbooks/nas-postgres-major-upgrade.md` as the model of a finished page.

## Steps

### 1. Check that it's a runbook

A runbook is for a procedure that will be done again. If the work was a one-off change (moving a bucket, restructuring a repo), it belongs in a migration record instead: say so, suggest `/migration`, and wait for the user before writing anything.

Some work is both, like a Postgres major upgrade: the procedure is a runbook, and what went wrong on this particular run is a migration record. Runbooks have no history section, so that story doesn't go here. Write the runbook, and tell the user the record half exists so they can run `/migration` for it.

### 2. Find the page

Look in `docs/runbooks/` and the **Runbooks** nav in `mkdocs.yml` for a runbook covering the same procedure.

- **No page:** create one. Name the file after the procedure in kebab-case (`nas-postgres-major-upgrade.md`) and add it to the Runbooks nav with a short label.
- **A page exists:** update it (step 4).

### 3. Gather the facts

Look in this order:

1. This session: the steps as they were done, the commands that worked, what was checked and what it printed, and anything that had to be redone.
2. Git and GitHub: `git log` and the PRs, for config changes the procedure made.
3. Live output already in the session (cluster or NAS). Don't run anything on the NAS; give the user the command instead.

Then list everything still missing, such as the date of the run, why a step is needed, or what a check should print, and ask the user about all of it in one message. Don't guess and don't leave TODOs. If the user doesn't know, write the step without that detail. A wrong step is worse than a missing explanation, because the next run will follow it.

### 4. Write the page

**New page:** fill the skeleton from the convention, in the imperative ("Scale the apps down"), since the reader is the person doing the next run. Keep the commands as they ran, so they're known to work, and say in the Overview what to change for the next run (the version numbers, for example), as the convention describes. Give every section its Check.

**Existing page:** compare the run in this session with the runbook, step by step.

- A step that was done differently, needed an extra command, or whose check printed something else: fix the step so the next run works first time. Add a `!!! warning` or `!!! note` where the run hit something a reader would otherwise miss.
- Always set the **Last run** line to this run's date and what was done.
- If the run matched every step, the Last run line is the only change, and there's nothing to ask the user.

### 5. Finish

1. Run the `humanizer` skill in embedded mode on the prose you wrote or changed. Leave code blocks, command output and link targets untouched.
2. Build the docs in strict mode with the repo's MkDocs (install `docs/requirements.txt` in a scratchpad venv if `mkdocs` isn't available):

    ```sh
    mkdocs build --strict -d <scratchpad>/site
    ```

    Then check what style.md asks: every command block titled, no numbered list restarting, the page in the nav.

3. Tell the user which page you created or changed, which steps you fixed and why, what you asked them, and the build result. Don't commit; the user commits when they've read the page.
