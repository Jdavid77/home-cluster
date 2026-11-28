# Migrations

Migration docs live in `docs/migrations/` and are listed under **Migrations** in the `nav` of `mkdocs.yml`. The reference example is `docs/migrations/nfs-single-share.md`.

A migration doc is a record of a one-off change: what changed, why, and how it was done. It's written during or just after the migration, in the past tense, so nobody mistakes it for a procedure to follow again. It isn't kept up to date afterwards, apart from its cleanup status.

Anything about how things work today belongs elsewhere: a procedure you'll repeat goes in a runbook (see [`runbooks.md`](runbooks.md)), and how the cluster is set up belongs in the repo itself, next to the config.

Formatting (code blocks, spacing, admonitions) follows [`style.md`](style.md).

## Page skeleton

```
# <Thing>: <from> to <to>

**Migrated:** <date>. <cleanup status>

<one or two paragraphs: what it was before, what it is now, the PR(s)>

## Decisions
## What changed
## What was done
### 1. <Step>
### 2. <Step>
…
## Rollback
## Cleanup
## Follow-ups
```

- **Title:** the thing that moved, then where from and to. Describe the end state when there's no clear "from" ("OMV compose stacks: own repo, managed by the plugin").
- **Intro:** no heading. What it was before, what it is now, and links to the PRs.
- **Decisions:** why it was done this way, and what was rejected and why.
- **What changed:** the before and after details: tables of what moved, the new layout, and what didn't change. Keep it short when the intro already says most of it, but don't leave it out.
- **What was done:** the procedure as it happened.
- **Rollback:** how it could be undone, and until when. Leave it out when there's no way back. It comes before Cleanup, because the cleanup usually ends it.
- **Cleanup:** what was removed, or still has to be, and when.
- **Follow-ups:** open work the migration left behind. Leave it out when there's none, and remove items once they're done, recording the outcome where it belongs.

## Cleanup status

The `**Migrated:**` line always ends with one of two forms:

- **Pending:** "Cleanup pending: <what's left>, see [Cleanup](#cleanup)."
- **Done:** "Cleaned up on <date>."

While the cleanup is pending, the Cleanup section lists what's left and when it's due ("once every app has run on the new paths for a while"). Once it's done, rewrite the section in the past tense with the date, switch the status line, and replace Rollback with one line saying it ended with the cleanup.

## Decisions

- **Short decisions:** one bullet each. State the decision, then why, then what was rejected and why.
- **Long decisions:** a decision that needs more than a short paragraph, for example one with error output, gets its own `### <question>` under Decisions ("### Why not the plugin's placeholders").

## What was done

One `### <n>. <Step>` per step, in the past tense ("### 3. Copied the data with the apps running"). The numbers allow cross-references ("with `PAIRS` set as in step 2"). Each step has:

- **What was done and why:** prose, with the commands as they were run in titled code blocks.
- **What was checked, and the result:** "It printed only the `===` lines."
- **Surprises:** anything that went wrong or differently from the plan, as a `!!! note` in the step where it happened.

Use a numbered list inside a step for a short sequence of manual actions, such as clicks in a UI.

## Commands

Commands appear as they were actually run, with the real paths, names and hosts, not placeholders. Reuse is a runbook's job; the record shows exactly what happened.

- **Secrets:** never inline. The command reads them from a file, an environment variable or a prompt.
- **One-off scripts:** the whole script goes in the doc, in a titled code block, since the doc is its only copy.
- **zsh and bash:** commands ran in zsh on the workstation. Note anything that differs in bash.
