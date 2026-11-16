# Skills

The set of agent skills one person uses, where they come from, and how they reach each place an agent runs.

## Language

**Skill**:
A folder of instructions (`SKILL.md` plus optional files) that an agent loads when a task matches its description.

**Own skill**:
A skill whose content is written and kept in this repo.
_Avoid_: my skill, custom skill, local skill

**Third-party skill**:
A skill written in someone else's repo and used here at a pinned commit.
_Avoid_: external skill, vendored skill

**Pin**:
The exact commit a third-party skill is used at.
_Avoid_: version, lock

**Surface**:
A place where skills are used: one Claude Code config, or one claude.ai account.
_Avoid_: target, agent, platform

**Bootstrap**:
The one-time creation of a new project, from choosing its stack to its first commits and standing instructions.
_Avoid_: scaffold, setup, init

**Process**:
A way of working that applies to every change in a project's life, such as testing, reviewing or committing; each process is its own skill.
_Avoid_: workflow, rules, conventions

**Project override**:
A project's own instructions taking the place of, or adding to, a skill's default for one rule; the project wins where they conflict.
_Avoid_: local precedence, customization
