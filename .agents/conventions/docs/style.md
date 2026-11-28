# Docs style

Formatting rules for every page in `docs/`. The page types add their own rules on top:

- `runbooks.md`: runbooks in `docs/runbooks/`
- `migrations.md`: migration records in `docs/migrations/`

## Code blocks

Every command block has a `title` that says where it runs:

| Title | Where |
|---|---|
| `NAS` | On the NAS, in the Compose Files folder unless the block `cd`s elsewhere |
| `Workstation` | Your machine, with `kubectl` on the cluster |
| `This repo` | The root of this repo |

Add a title to the table when a page needs a new place, and say what it means on the page itself. Titles need `pymdownx.highlight`, which `mkdocs.yml` enables. A whole script is titled with its file name instead (`title="obsidian-b2-to-r2.sh"`), and the commands that ran it get their own block. Blocks that aren't commands (error output, a file tree) have no title.

````md
1. Scale them down.

    ```sh title="This repo"
    .claude/skills/postgres-apps/scripts/postgres-apps.sh down
    ```
````

- Manual steps (editing a file in another repo, clicking in a UI) are prose, not comments in a code block.
- One block holds commands for one place only.
- Keep long commands as short lines. A terminal can split a long line on paste.
- Never put secrets in a command. Read them from a file on the host or prompt for them, as the `pg_dumpall` step of the Postgres runbook does with `PGPASSWORD`.

## Admonitions

Use `!!! warning` for something that can break things or lose data if missed, and `!!! note` for something surprising the reader should know. Indent the body 4 spaces.

## Spacing

- A blank line before and after every heading, paragraph, list, code block and admonition.
- Anything inside a list item (paragraphs, code blocks, nested lists) is indented 4 spaces. Python-Markdown needs 4. With fewer, the block drops out of the list and the numbering restarts.
- A numbered list whose items hold blocks has a blank line between every item, so it renders with even spacing.

## Checking a page

Build the docs in strict mode, then open the page. Make sure no numbered list restarts, every command block has its title, and the lists are spaced evenly:

```sh title="This repo"
pip install -r docs/requirements.txt
mkdocs build --strict
```

A new page also needs an entry in the `nav` of `mkdocs.yml`.
