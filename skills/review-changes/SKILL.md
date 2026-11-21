---
name: review-changes
description: End each change by asking how to review it, then run a single review in a fresh subagent or a multi-round review-and-fix loop against a baseline. Use at the end of every change (feature, fix, bootstrap step), or when the user asks for a review or a review loop on uncommitted work, a branch, or since a commit.
---

# Review changes

## Project overrides

Before following a step, check the project's `CLAUDE.md` and `AGENTS.md`, and the files they link to, for rules on the same step. Where they conflict with this skill, follow the project. Where they add to it, do both. Project rules also extend the review checklist below.

## The question

At the end of each change, give a one-line summary of the change, then ask with AskUserQuestion:

- **Review, then commit:** one review pass on the uncommitted changes; fix the findings the user accepts; then commit.
- **Review-and-fix loop, then commit:** run the loop below, then commit.
- **Commit, then review:** commit now, review `HEAD`, and put any accepted fixes in a follow-up commit (`fix:` or `refactor:`).
- **Commit, skip review:** commit without reviewing.

No review or loop starts until the user has chosen. If AskUserQuestion is unavailable, ask in plain text. If no one is available to answer, commit, skip the review, and say so. Commits follow `commit-changes`.

The user can also ask for a review or a loop at any time, on the current branch or since a given commit. Ask the loop setup questions first in that case too.

## Single review

Reviews always run in a **fresh subagent** (the Agent tool with a general-purpose agent, never a fork of the current context). That way the reviewer judges the code on its own merits, without the reasoning that produced it. Give the subagent:

- the repo path and the exact diff command: `git diff HEAD` plus untracked files for review-then-commit, or `git show HEAD` for commit-then-review
- the paths to `CLAUDE.md` and `AGENTS.md`, which it must read first
- the checklist below, plus the project's own checklist additions
- an instruction to read whatever surrounding code it needs, to not edit any files, and to return findings ranked by severity with `file:line`, a one-sentence problem, and a suggested fix. Each finding is tagged **blocking** (bug, regression, security, or project-rule violation) or **improvement**. It should say "no findings" rather than invent nitpicks.

Checklist:

1. **Correctness:** bugs, edge cases, error handling, security (injection, mass assignment, authz), and regressions in callers of the changed code.
2. **Design:** the project's architecture and layer boundaries respected, behaviour in the domain, responsibilities in the right place.
3. **Readability:** clear naming in the project's language (its glossary), value objects where they add meaning, code that reads without comments explaining it.
4. **Minimalism and simplicity:** unneeded code, abstractions, dependencies, configuration or files. Is there a simpler correct solution?
5. **Performance:** N+1 queries, unbounded result sets, needless loops or allocations, and missing indexes for new queries.
6. **Tests:** as `write-tests` defines them. Flag tests that exist only for coverage or that over-mock.
7. **Docs:** the docs the change makes wrong are updated, as `document-changes` says.
8. **Commit:** as `commit-changes` defines it.
9. **Project rules:** everything the project's instructions add.

Present the findings to the user concisely, and ask which to fix (all, some, or none) before changing anything.

## Review-and-fix loop

The goal is the smallest, simplest, performant and readable diff against the baseline, with no bugs and no regressions.

**Setup.** When the user picks the loop, ask both questions in one AskUserQuestion call:

- **Maximum rounds:** 1, 2, 3 or 5. The user can type 4.
- **Baseline:** the uncommitted changes (`HEAD`), the whole branch (`git merge-base main HEAD`), or since a specific commit (the user types the SHA). At the end of a change, the default is the uncommitted changes.

Resolve the baseline to a SHA. Run the project's full check (formatter, static analysis, every test suite, and any generated-file freshness checks) once before round 1, and note anything already failing so it is not mistaken for a regression.

Once the user has approved the loop, run all rounds without stopping to ask, unless something below says to stop. **Each round:**

1. **Review.** Start a new fresh reviewer subagent. Never reuse or fork an earlier one. Give it everything a single review gets, but with `git diff <baseline>` plus untracked files as the diff. Add these instructions:
   - Judge the whole diff against the baseline, not just the last round's fixes.
   - Flag anything in the diff that could be removed, or done with less code, without losing behaviour.
   - Check the callers and the tests of changed code for regressions. Running the test suite is allowed, but editing files is not.
   - Do not re-raise a finding listed as dismissed in an earlier round unless there is new evidence.
2. **Fix.** In the main context, fix each valid finding with the smallest change that resolves it. Do not refactor unrelated code or add features. For each real bug, add a test that fails without the fix. Do not apply a finding that is wrong, or that would undo an earlier round's fix; record it as dismissed with a one-line reason.
3. **Test.** Run the full check. If something fails because of this round's fixes, fix it or revert that fix before the round ends. Never end a round red.
4. **Decide.** Stop early when the reviewer reports no blocking findings and no new improvements worth making, and the check is green. Otherwise, start the next round until the maximum is reached.

Stop and ask the user instead of continuing if a fix would change behaviour the user asked for, would need a new dependency, or would go against a project rule.

**After the loop**, report briefly:

- a small table: round → findings (blocking / improvement) → fixed → dismissed, with reasons
- the final check status
- `git diff --stat <baseline>`
- anything still unresolved

Then commit. Loop fixes on uncommitted work become part of that change's commit. When the baseline includes existing commits, the fixes go in a follow-up commit (`fix:` or `refactor:`). If blocking findings remain after the last round, ask before committing.
