# skills

My Brain: the skills I use and where they come from. [nerve](https://github.com/medilies/nerve) carries it to every surface: each Claude Code config and each claude.ai account. Words used here are defined in [GLOSSARY.md](GLOSSARY.md) and in [nerve's glossary](https://github.com/medilies/nerve/blob/main/GLOSSARY.md).

- `skills/<name>/`: own skills. Edit them only here.
- `skills.toml`: the Claude Code configs, and third-party skills pinned to a commit.

## Use

Commands and what `sync` does: [nerve's README](https://github.com/medilies/nerve#use).

| To | Do |
| --- | --- |
| Set up a new machine | `go install github.com/medilies/nerve/cmd/nerve@latest`, then `gh repo clone medilies/skills && cd skills && nerve sync` |
| Refresh everything | `nerve sync` |
| Move the nerve version CI checks with | Change `NERVE` in [.github/workflows/ci.yml](.github/workflows/ci.yml) |

## Notes

- Own skills open with a `## Project overrides` section: a project's `CLAUDE.md`/`AGENTS.md` win rule by rule.
- Never edit a skill on claude.ai.
