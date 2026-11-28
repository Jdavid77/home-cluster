# Runbooks

Runbooks live in `docs/runbooks/` and are listed under **Runbooks** in the `nav` of `mkdocs.yml`. A runbook is a procedure you repeat and keep up to date; a one-off change gets a migration record instead (see [`migrations.md`](migrations.md)). The reference example is `docs/runbooks/nas-postgres-major-upgrade.md`.

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

## Formatting

Code blocks, spacing and admonitions follow [`style.md`](style.md). On top of that:

- The Overview says what the code block titles mean.
- A blank line between steps, always. Every Steps list then renders loose, with the same spacing whether or not its steps have code blocks.
- No blank line between Check bullets, unless one holds a code block.

Check the page as `style.md` describes before committing.
