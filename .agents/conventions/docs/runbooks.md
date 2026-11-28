# Runbooks

Runbooks live in `docs/runbooks/` and are listed under **Runbooks** in the `nav` of `mkdocs.yml`. The reference example is `docs/runbooks/nas-postgres-major-upgrade.md`.

## Page skeleton

```
# <Thing>: <operation>

<one paragraph: what the runbook covers, and what it doesn't touch>

**Last run:** <date>, <what was done> (see [History](#history)).

## Overview
## Prerequisites
## 1. <Phase>
## 2. <Phase>
…
## Rollback
## Cleanup
## History
### <what was done>, <date>
```

- **Top of the page:** only the scope paragraph and the **Last run** line.
- **Overview:** how the procedure works and why it was chosen over the alternatives, and how to adapt the commands for the next run (for example, which version numbers to replace). It also says what the code block titles mean. A warning that applies to the whole page goes here, as a `!!! warning` at the end.
- **Phases:** the procedure, in order, as `## <n>. <Phase>` headings. The numbers make cross-references possible ("until phase 3"). Prerequisites, Rollback, Cleanup and History stay unnumbered, because they sit outside the sequence.
- **Rollback and Cleanup:** leave either out when the procedure doesn't need it.
- **History:** a `###` per run, with bullets for what happened, what went wrong and what changed afterwards. It's a log, so it doesn't get Steps or Checks.

## Shape of each section

Prerequisites, every phase, Rollback and Cleanup have the same three parts, in this order:

1. **Intro:** one or two sentences on why the section exists or when it applies. No label.
2. **Steps:** a numbered list of the actions, straight after the intro, with no label. Each step starts with the action ("Build the PostGIS image.", "Run one backup by hand:"), and any explanation follows in the same step.
3. **Check:** a bullet list of what must be true before going on. It starts with the lead-in "Before moving on, check that:", or "Then check that:" in Rollback and Cleanup, and each bullet completes that sentence.

Things to verify by looking at output belong in Check. When a check needs a multi-line command, the command becomes a step, and the Check bullet only states the result ("Every database shows the same table count on both servers."). What to do when a check fails goes in a paragraph after the Check list.

## Checks

- **One-line command:** inline code, followed by the expected result: "`docker port postgres18` shows `5434`."
- **Command that doesn't fit on one line:** a code block inside the bullet, indented 4 spaces, with blank lines around it.
- **Where it runs:** say so in the bullet when it isn't obvious ("… on the NAS prints nothing").

## Code blocks

Every command block has a `title` that says where it runs:

| Title | Where |
|---|---|
| `NAS` | On the NAS, in the Compose Files folder |
| `Workstation` | Your machine, with `kubectl` on the cluster |
| `This repo` | The root of this repo |

Add a title to the table in the runbook's Overview if a runbook needs a new place. Titles need `pymdownx.highlight`, which `mkdocs.yml` enables.

````md
1. Scale them down.

    ```sh title="This repo"
    .claude/skills/postgres-apps/scripts/postgres-apps.sh down
    ```
````

- Manual steps (editing a file in another repo, clicking in a UI) are prose in the step, not comments in a code block.
- One block holds commands for one place only.
- Keep long commands as short lines. A terminal can split a long line on paste.
- Never put secrets in a command. Read them from a file on the host instead, as the `pg_dumpall` step does with `PGPASSWORD`.

## Spacing

- A blank line before and after every heading, paragraph, list, code block and admonition.
- A blank line between steps, always. Every Steps list then renders loose, with the same spacing whether or not its steps have code blocks.
- No blank line between Check bullets, unless one holds a code block.
- Anything inside a list item (paragraphs, code blocks, nested lists) is indented 4 spaces. Python-Markdown needs 4. With fewer, the block drops out of the list and the numbering restarts.

## Checking a runbook

Build the docs in strict mode, then open the page. Make sure no numbered list restarts, every code block has its title, and the Steps lists are spaced evenly:

```sh title="This repo"
pip install -r docs/requirements.txt
mkdocs build --strict
```
