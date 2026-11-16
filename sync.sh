#!/bin/sh
# Install or refresh every skill I use, in both Claude Code configs.
set -e
add() {
  for cfg in "$HOME/.claude-personal" "$HOME/.claude"; do
    CLAUDE_CONFIG_DIR="$cfg" npx -y skills@1.7.6 add "$@" -g -a claude-code codex -y
  done
}
add medilies/skills --skill '*'
add mattpocock/skills --skill grill-with-docs grilling domain-modeling wayfinder research prototype setup-matt-pocock-skills code-review
add microsoft/tui-test --skill tui-test
# Links left behind by removed skills
find "$HOME/.claude-personal/skills" "$HOME/.claude/skills" -maxdepth 1 -xtype l -delete
