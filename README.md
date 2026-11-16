# brain

My Brain: the skills, settings and standing instructions my agents work with. [nerve](https://github.com/medilies/nerve) carries it to every Claude Code config; its skills reach claude.ai as plugins. Words used here are defined in [GLOSSARY.md](GLOSSARY.md) and in [nerve's glossary](https://github.com/medilies/nerve/blob/main/GLOSSARY.md).

- `brain.toml`: the nerve release and the profiles (`personal`, `work`).
- `.claude-plugin/marketplace.json`: the plugins: own skills as `brain`, and third-party skills pinned to a commit.
- `plugins/brain/skills/<name>/`: own skills: processes, `start-project`, and a stack skill per stack (`go-stack`, …). Invoked as `/brain:<name>`.
- `settings/`: Claude Code settings for every config (`base.json`, which also enables the plugins) and per profile.

How each of these reaches a config, and every command: [nerve's README](https://github.com/medilies/nerve#readme).

## Use

Day to day, ask Claude through the `nerve` skill: "sync my brain", "remember that I always…".

| To | Do |
| --- | --- |
| Set up a new machine | Install nerve, `gh repo clone medilies/brain ~/dev/brain`, then `nerve init ~/dev/brain ~/.claude-personal=personal ~/.claude=work` and `nerve sync` |
| Refresh everything | `nerve sync` |
| Move to a new nerve release | Change `nerve` in `brain.toml`, commit, `nerve sync` |
| Use the skills on claude.ai | Once, on the personal account only: add `medilies/brain` as a plugin marketplace and install its plugins |

## Rules

- Nothing secret or identifying goes here: this repo is public. Such settings go in the local overlay, `~/.config/nerve/overlays/<profile>.json`.
- Every own skill opens with a `## Project overrides` section: a project's `CLAUDE.md`/`AGENTS.md` win rule by rule. CI checks it.
- Never edit a skill on claude.ai.
