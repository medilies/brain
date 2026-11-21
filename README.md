# brain

My Brain: the skills my agents work with, and the projects that use them. [nerve](https://github.com/medilies/nerve) carries each project what it lists, and nothing else. Words used here are defined in [GLOSSARY.md](GLOSSARY.md) and in [nerve's glossary](https://github.com/medilies/nerve/blob/main/GLOSSARY.md).

- `brain.json`: third-party skills pinned to a commit, common settings, and the projects with what each one gets.
- `skills/<name>/`: own skills: processes, `start-project`, and a stack skill per stack (`go-stack`, …).

How each of these reaches a project, and every command: [nerve's README](https://github.com/medilies/nerve#readme).

## Use

Day to day, ask Claude through the `nerve` skill, in a project the Brain lists: `/nerve`, "use my Go stack here".

| To | Do |
| --- | --- |
| Set up a new machine | Install nerve, `gh repo clone medilies/brain ~/dev/skills/brain`, then `nerve init ~/dev/skills/brain` |
| Carry the Brain to a project | In its checkout: `nerve project add <name>`, then `nerve sync --here` |
| Use a skill in a project | `nerve skill add <name>` |
| Move to a new nerve release | Install it on each machine, and set its version in `.github/workflows/ci.yml` |

## Rules

- Nothing secret or identifying goes here: this repo is public. No client or employer names, as project names or anywhere else. Such settings go in the local overlay, `~/.config/nerve/overlays/<project>.json`.
- Every own skill opens with a `## Project overrides` section: a project's `CLAUDE.md`/`AGENTS.md` win rule by rule. CI checks it.
- Never edit a skill on claude.ai.
