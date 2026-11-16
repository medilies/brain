# skills

My agent skills, and the list of every skill I use. This repo is the source of truth for every surface: each Claude Code config and each claude.ai account. The words used here are defined in [GLOSSARY.md](GLOSSARY.md).

- `skills/<name>/`: own skills. Edit them only here.
- `skills.toml`: the Claude Code configs, and third-party skills pinned to a commit.
- `cmd/skills`: the tool that installs, pins and checks them.

## Use

| To | Do |
| --- | --- |
| Install or refresh everything | `go run ./cmd/skills sync` |
| Edit or add an own skill | Change `skills/<name>/`, then `sync`. Linked from this checkout, so edits are live at once. |
| Add a third-party skill | Add it to a `[[source]]` in `skills.toml` (a new source needs a full commit SHA), then `sync` |
| Move a pin | `go run ./cmd/skills update <repo> [sha]`: shows the upstream diff, then rewrites the pin. Review it, commit, `sync`. |
| Remove a skill | Delete it from `skills.toml` or `skills/`, then `sync` |
| Validate | `go run ./cmd/skills check` (CI runs it too) |
| Set up a new machine | `gh repo clone medilies/skills && cd skills && go run ./cmd/skills sync` |

## What sync does

- Links every skill into `<config>/skills/` for each config in `skills.toml`: own skills from this checkout, third-party ones from a cache at their pin.
- Removes only links it made itself (listed in `<config>/skills/.skills-sync.json`), and refuses to replace a real folder. A link with a skill's name is replaced, whoever made it.
- Builds `dist/<name>.zip` for every skill claude.ai accepts. A skill whose frontmatter claude.ai rejects is listed as Claude Code only.
- Reports drift on claude.ai. Each config downloads its account's claude.ai skills into `<config>/skills/synced/`, and sync checks that a copy there holds every file of the skill unchanged, printing `missing` or `stale` with the zip to upload.

## claude.ai

claude.ai only takes skills uploaded by hand (Customize > Skills > Upload a skill). After a `sync` reports drift, upload the named zips to that account. Never edit a skill on claude.ai.

## Notes

- A personal skill always wins over a project's skill of the same name; nothing changes that. Own skills instead open with a `## Project overrides` section: the project's `CLAUDE.md`/`AGENTS.md` win rule by rule.
- Why an own tool and not the `skills` CLI or a Claude plugin: [docs/adr/0001-own-sync-tool.md](docs/adr/0001-own-sync-tool.md).
