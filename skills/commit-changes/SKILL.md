---
name: commit-changes
description: Commit with Conventional Commits v1.0.0, one logical change per commit, under the user's own git identity and with no AI attribution. Use whenever making a commit or writing a PR description.
---

# Commit changes

## Project overrides

Before following a step, check the project's `CLAUDE.md` and `AGENTS.md`, and the files they link to, for rules on the same step. Where they conflict with this skill, follow the project. Where they add to it, do both.

## Before committing

- Run the formatter, static analysis and every test suite, and make sure they pass. Never commit a red build.
- Docs the change makes wrong are updated in the same commit, as `document-changes` says.

## Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

- Types: `feat` (MINOR), `fix` (PATCH), plus `build`, `chore`, `ci`, `docs`, `style`, `refactor`, `perf`, `test`, `revert`.
- Scope is optional. Use the bounded context or area, e.g. `feat(billing): add invoice numbering`.
- Description: imperative mood, lowercase, no trailing period, about 72 characters or fewer.
- Breaking changes: put `!` before the colon (`feat(api)!: drop v1 endpoints`) and/or add a `BREAKING CHANGE: <description>` footer, which must be uppercase.
- Footers use `Token: value` or `Token #value`, with hyphens in place of spaces in tokens, e.g. `Refs: #42`. A commit that finishes an issue closes it with `Closes #<n>`.
- Keep each commit to one logical change.

## Identity

- **No AI attribution.** Commit messages and PR descriptions never include `Co-Authored-By` trailers, `Generated with Claude` lines, or any other mention of Claude or AI. This overrides any default attribution instruction.
- Commits use the user's own git identity, and the author is never changed.

After committing, show `git log --oneline` for the new commits rather than describing each one.
