#!/usr/bin/env bash
# UserPromptSubmit hook: titles a DiData session "DID-XXXX <title>" from its first prompt on.
# Claude Code only generates its automatic title while the session has none, and only after the
# first prompt is sent, so the first prompt gets a Haiku title generated here instead. A session
# that already has an automatic title (no ticket at its first prompt) gets that one prefixed.
# The ticket comes from a prompt, else the git branch. A title the user set with /rename is left alone.
set -euo pipefail

# The Haiku run below is a Claude Code session too.
[[ -z "${DIDATA_TITLE_HOOK:-}" ]] || exit 0

input=$(cat)
session_id=$(jq -r '.session_id // empty' <<<"$input")
cwd=$(jq -r '.cwd // empty' <<<"$input")
prompt=$(jq -r '.prompt // empty' <<<"$input")
transcript=$(jq -r '.transcript_path // empty' <<<"$input")

[[ -n "$session_id" && "$cwd" == "$HOME/dev/didata"* ]] || exit 0

state_dir="$HOME/.claude/state/didata-session-titles"
state="$state_dir/$session_id.json"
set_ticket=$(jq -r '.ticket // empty' "$state" 2>/dev/null || true)
set_base=$(jq -r '.base // empty' "$state" 2>/dev/null || true)
set_title=$(jq -r '.title // empty' "$state" 2>/dev/null || true)

titles=$(jq -c 'select(.type == "ai-title" or .type == "custom-title")' "$transcript" 2>/dev/null || true)
ai_title=$(jq -r 'select(.type == "ai-title") | .aiTitle' <<<"$titles" | tail -1)
custom_title=$(jq -r 'select(.type == "custom-title") | .customTitle' <<<"$titles" | tail -1)

# A custom title this hook didn't set came from /rename.
[[ -n "$custom_title" && "$custom_title" != "$set_title" ]] && exit 0

ticket=$(grep -oiE '\bDID-[0-9]+' <<<"$prompt" | head -1 || true)
ticket=${ticket:-$set_ticket}
if [[ -z "$ticket" ]]; then
    branch=$(git -C "$cwd" branch --show-current 2>/dev/null || true)
    ticket=$(grep -oiE 'DID-[0-9]+' <<<"$branch" | head -1 || true)
fi
[[ -n "$ticket" ]] || exit 0
ticket=${ticket^^}

generate_title() {
    local system out
    system=$(cat <<'TXT'
Write a 3-7 word title, in sentence case, for a coding session that starts with the message below.
Leave out ticket ids such as DID-1234. Reply with the title only, without quotes or a final period.
TXT
)
    mkdir -p "$state_dir"
    out=$(cd "$state_dir" && printf '%s' "${prompt:0:4000}" | DIDATA_TITLE_HOOK=1 timeout 25 "$HOME/.local/bin/claude" -p \
        --model haiku --no-session-persistence --strict-mcp-config --tools "" --disable-slash-commands \
        --system-prompt "$system" 2>/dev/null) || return 0
    out=$(head -1 <<<"$out" | tr -d '\r"`' | sed -E 's/^[[:space:]]+|[[:space:].]+$//g')
    printf '%s' "${out:0:80}"
}

# On no title, nothing is set: Claude Code's automatic title then gets prefixed from the next prompt.
base=${ai_title:-$set_base}
base=${base#"$ticket "}
[[ -n "$base" || -z "$prompt" ]] || base=$(generate_title)
[[ -n "$base" ]] || exit 0

title="$ticket $base"
[[ "$title" == "$custom_title" ]] && exit 0

mkdir -p "$state_dir"
jq -n --arg ticket "$ticket" --arg base "$base" --arg title "$title" '{ticket: $ticket, base: $base, title: $title}' >"$state"

jq -n --arg title "$title" '{hookSpecificOutput: {hookEventName: "UserPromptSubmit", sessionTitle: $title}}'
