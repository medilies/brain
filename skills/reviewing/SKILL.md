---
name: reviewing
description: Multi-agent review of a branch against its target, or of the whole project, at a fast, normal or deep grade - impact explorers, parallel reviewers that run new logic on edge inputs, then verification of every finding. Runs only when the user invokes it.
argument-hint: "[fast | normal | deep] [target branch | project]"
disable-model-invocation: true
---

# Reviewing

## Project overrides

Before following a step, check the project's `CLAUDE.md` and `AGENTS.md`, and the files they link to, for rules on the same step. Where they conflict with this skill, follow the project. Where they add to it, do both. Project rules also extend the reviewers' checklist.

## Scope

The first word of `$ARGUMENTS` may be a grade: `fast`, `normal` or `deep`; the default is `normal`. If the rest is `project`, review the whole project: follow the steps below with the changes under "Project review" below. Otherwise review the diff from the merge-base with the target to HEAD. The target is the rest of `$ARGUMENTS` if given, else the PR's base branch, else the repo's default branch. Report only; don't edit code.

The two subagents, `impact-explorer` (finds locations) and `code-reviewer` (reviews and runs code), are project agents. The reviewers' checklist is in `../../agents/code-reviewer.md`, relative to this skill's directory. Write every file this review creates to the session's scratchpad, or to a new temporary directory when there is none; that is "the scratchpad" below.

## Grades

The grade sets how many subagents run, and on which model.

| | fast | normal | deep |
|---|---|---|---|
| Explorers (step 2) | none | 2 | 1 per module holding changed code, at most 3 |
| A reviewers (step 4) | none | 1 per module, at most 2 | 1 per module, at most 3 |
| B reviewer (step 4) | none | 1 | 1 |
| Other reviewer (step 4) | 1, focus "fast" | none | none |
| `needs:` fact checks (step 5) | you | 2 explorers | 1 explorer per module, as in step 2 |
| Refute (step 5) | you, on unreproduced Correctness and Tests findings | 1 reviewer, on unreproduced Correctness and Tests findings | 1 reviewer on opus, on every Correctness and Tests finding |

Explorers run on haiku and reviewers on sonnet, as their agent files set; only deep's refuter is spawned with `model: opus`. You are the session's model.

- A diff under 300 changed lines drops `normal` to `fast`. `deep` always runs in full.
- A project review runs at `normal` or `deep`; `fast` becomes `normal`.

## Process

1. **Diff.** Save the diff and `git log --format='%h %s%n%b' <merge-base>..HEAD` to the scratchpad. From `git diff --stat` and the diff's signature lines only, list the changed, added, removed and renamed public symbols (functions, types, interfaces, config keys, routes, schema fields, events). Get the signature lines with a pattern fitted to the project's languages, e.g. `git diff -U0 <merge-base>..HEAD | grep -E '^(\+\+\+|[+-].*\b(class|interface|enum|struct|type|function|func|def|const|export)\b)'`.

2. **Impact map.** Skip this step in fast. Spawn the `impact-explorer` subagents the grade gives, each with a report path in the scratchpad and, in deep, its module's symbols, to find, for those symbols:
   1. callers, implementations and consumers outside the diff;
   2. existing utilities or library functions that do what new code does;
   3. docs, comments, READMEs and changelogs that mention them;
   4. remaining references to removed or renamed symbols.

   If the signature lines exceed ~300, pass the diff path to the explorers and have them extract the symbols themselves.

3. **Tools, while the explorers run.** Run the project's strict type checker, linter, and dead-code/duplicate detectors on the branch, each under 4 GiB of memory and two CPUs (on Linux with systemd: `systemd-run --user --scope --quiet -p MemoryMax=4G -p MemorySwapMax=0 -p CPUQuota=200% <command>`; elsewhere, no limit). A tool killed by its limit is reported as not run. Save the output to the scratchpad, separating errors on lines this branch touched from pre-existing ones. Collect the settled decisions for this change from the project's memory notes and ADRs, if any, and the commit log.

4. **Review.** In fast, spawn one `code-reviewer` with focus "fast", the diff path and the inputs below. Otherwise spawn the A and B reviewers the grade gives, each with the commit log path, the tool output path, the settled decisions, your scratchpad path and one focus:
   - **A. New logic: run it and try to break it.** One A reviewer per module (directory or package) holding new code, up to the grade's cap. Give each its module's diff slice (`git diff <merge-base>..HEAD -- <paths>`, saved to the scratchpad) and the full diff path for context. An A reviewer stays inside its slice: callers, permissions, CI, docs and settled performance figures belong to B. Spawn the A reviewers as soon as step 3 is done, without waiting for the explorers.
   - **B. Integration:** callers, permissions, data volume, CI, docs, migrations, with the full diff and the explorers' report paths. Spawn it once the explorers have reported.

   Pass facts and settled decisions, not your own conclusions about the code.

   Until the reviewers report, read no source or diff content yourself: steps 1-4 run on tool output, signature lines and the explorers' replies.

5. **Verify.** Check every finding against the code, batching the reads for all findings into as few calls as possible. Check the `needs:` claims as the grade says: yourself in fast, else in one batch to the grade's `impact-explorer` subagents, then judge each finding on the evidence they return. Drop any bug without a concrete triggering input. Merge duplicates. Use the impact map to check for consumers the reviewers missed.

   **Refute.** Take the Correctness and Tests findings the grade names. In fast, try to break each one yourself: find the guard that prevents it, or reproduce it under the reviewers' resource limits. Otherwise, spawn one `code-reviewer` (in deep with `model: opus`) with focus "refute", the full diff path, your scratchpad path and those findings as the reviewers wrote them, without your verdicts. Keep a finding that is reproduced, drop one refuted with quoted code, and judge the rest yourself. Skip this when no such finding remains.

6. **Report.** Findings sorted by checklist priority, each with file:line, the criterion it violates, what goes wrong, and a suggested fix. Then the findings tagged `settled`, under "Settled: confirm these still hold". Pre-existing problems separately, briefly. End with a one-line verdict: ship / ship after fixes / needs rework.

## Project review

There is no diff, so every issue counts and nothing is pre-existing. The steps change as follows:

1. **Modules.** Instead of a diff, list the modules (directories or packages) with their size, and rank them by churn: `git log --since=6.months --name-only --format= | sort | uniq -c | sort -rn`. Save both to the scratchpad. Pick at most three modules to review in depth, the most churned first, unless the user named some.
2. **Map.** The explorers find, for the picked modules: their entry points and public symbols, their callers in other modules, utilities duplicated across modules, and the docs that describe them.
3. **Tools.** Run them on the whole project. All their output counts.
4. **Review.** Give each A reviewer one picked module's paths, with focus "project: whole module", instead of a diff slice. B gets the module list and the explorers' reports, with focus "project: integration", and reviews how the modules fit together. Always use the subagents.
5. **Verify** and **Refute** as above, with module paths instead of the diff path.
6. **Report.** Findings without a pre-existing section. Name the modules that weren't reviewed in depth. End with the three findings to fix first instead of a verdict.
