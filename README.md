# skills

My agent skills, and the list of every skill I use.

- `skills/<name>/SKILL.md`: skills I write. Edit them only here.
- `sync.sh`: installs or refreshes every skill, mine and third-party, with the [`skills` CLI](https://github.com/vercel-labs/skills).

## How it lays out

`sync.sh` keeps one copy of each skill in `~/.agents/skills`, and links it from both Claude Code configs (`~/.claude-personal/skills` and `~/.claude/skills`). Selecting the `codex` agent is what makes the CLI keep one shared copy instead of copying into each config.

Never edit `~/.agents/skills`: the next sync overwrites it.

## Use

| To | Do |
| --- | --- |
| Edit or add one of my skills | Change `skills/<name>/`, commit, push, `./sync.sh` |
| Add a third-party skill | Add an `add` line to `sync.sh`, then run it |
| Update everything | `./sync.sh` |
| Remove a skill | `npx -y skills@1.7.6 remove <name> -g -y`, delete it from `sync.sh` or `skills/`, then `./sync.sh` |
| Set up a new machine | `gh repo clone medilies/skills && cd skills && ./sync.sh` |
| Use a skill on claude.ai | Upload a zip of its folder. Never edit it there. |

## Notes

- Changes to my skills show only after they are pushed: `sync.sh` installs from GitHub.
- A global skill wins over a project's own copy of the same name, so in repos that commit their own skills (e.g. Matt Pocock's), these versions are the ones used.
- The CLI is pinned to the version this setup was tested with. Bump it on purpose.
