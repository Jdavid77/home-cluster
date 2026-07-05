---
name: commit
description: Stage and commit changes following this repo's commit conventions. Use when the user asks to commit, wants to make a commit, or asks how to write a commit message.
---

# Commit

Read the commit conventions at `.agents/conventions/repo/commit-conventions.md`, then:

1. Run `git status` to see what has changed.
2. Ask the user which files to stage, unless they've already specified.
3. Draft a commit message following the conventions — propose it to the user before committing.
4. Run `git add <files>` and `git commit -m "<message>"` once the user confirms.
