---
name: document-changes
description: Keep docs true in the same commit as the code they describe - one home per fact, docs laid out by reader, ADRs as records, diagrams over walls of text. Use whenever a change touches behaviour, names, commands, config or architecture, and when writing or reorganizing docs.
---

# Document changes

## Project overrides

Before following a step, check the project's `CLAUDE.md` and `AGENTS.md`, and the files they link to, for rules on the same step. Where they conflict with this skill, follow the project. Where they add to it, do both. The project's instructions say which doc owns which fact.

## Rules

- **Docs change in the same commit as the code they describe.** A change updates every doc it makes wrong: README, `docs/*.md`, schemas' descriptions, the glossary (its code column included) and `docs/agents/`. Before committing, grep the docs for each key, flag, command, file and identifier the change renames or removes.
- **Each fact lives in one doc;** the others link to it.
- **Never list in full what the code lists:** name a few as examples.
- **User docs say what the tool does, not how:** no internals, no history. History is in git, decisions in ADRs (`docs/adr/`), which are records and aren't updated.
- **A screen shown in a doc is copied from a real run,** never drawn by hand.
- Short sentences, and lists over long paragraphs.
- **Diagrams beat walls of text.** When an explanation would take more than a short paragraph (architecture, request flow, aggregate relationships, CI pipeline), use a diagram: Mermaid in repo docs; in chat, an inline visual if available, otherwise a Mermaid code block.

## Layout

Lay the docs out by reader, and give each fact one home:

- **Users:** the README (what it is, install, a short usage example), then one `docs/<topic>.md` per topic once the README would grow past that.
- **Contributors:** `docs/development.md` (commands, architecture diagram, issues, releasing), `docs/adr/` for decisions (records, never updated), and `docs/left-out.md` once there is something deliberately left out, with the reason.
- **Agents:** `CLAUDE.md` (rules and the glossary only) and `docs/agents/<topic>.md` for how-tos the agent needs for specific jobs, linked from `CLAUDE.md`.

Create a doc only when there is something to put in it.
