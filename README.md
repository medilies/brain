# brain

My Brain: the skills, settings and standing instructions my agents work with. [nerve](https://github.com/medilies/nerve) carries it to every surface: each Claude Code config and each claude.ai account. Words used here are defined in [GLOSSARY.md](GLOSSARY.md) and in [nerve's glossary](https://github.com/medilies/nerve/blob/main/GLOSSARY.md).

- `brain.toml`: the nerve release, the profiles (`personal`, `work`), and third-party skills pinned to a commit.
- `skills/<name>/`: own skills: processes, `start-project`, and a stack skill per stack (`go-stack`, …).
- `settings/`: Claude Code settings for every config (`base.json`) and per profile.

How each of these reaches a config, and every command: [nerve's README](https://github.com/medilies/nerve#readme).

## Use

Day to day, ask Claude through the `nerve` skill: "sync my brain", "remember that I always…".

| To | Do |
| --- | --- |
| Set up a new machine | Install nerve, `gh repo clone medilies/brain ~/dev/brain`, then `nerve init ~/dev/brain ~/.claude-personal=personal ~/.claude=work` and `nerve sync` |
| Refresh everything | `nerve sync` |
| Move to a new nerve release | Change `nerve` in `brain.toml`, commit, `nerve sync` |

## Rules

- Nothing secret or identifying goes here: this repo is public. Such settings go in the local overlay, `~/.config/nerve/overlays/<profile>.json`.
- Every own skill opens with a `## Project overrides` section: a project's `CLAUDE.md`/`AGENTS.md` win rule by rule. CI checks it.
- Never edit a skill on claude.ai.
