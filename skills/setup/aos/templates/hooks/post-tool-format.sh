#!/usr/bin/env bash
# aos post-tool-format — auto-format the edited file after Edit/Write (PostToolUse).
# Reads .claude/hooks/config.env; runs $FORMAT_CMD on the file Claude just touched.
# No-op if FORMAT_CMD is empty. PostToolUse cannot block; this is fail-silent.
# Portable: bash + POSIX; the formatter command comes from config (lang-agnostic).
set -u

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
CFG="$ROOT/.claude/hooks/config.env"
[ -f "$CFG" ] || exit 0
# shellcheck disable=SC1090
. "$CFG"
[ -z "${FORMAT_CMD:-}" ] && exit 0

# PostToolUse delivers a JSON payload on stdin; pull out the edited file path.
payload="$(cat 2>/dev/null)"
file="$(printf '%s' "$payload" \
  | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]+"' | head -1 \
  | sed -E 's/.*:[[:space:]]*"([^"]+)".*/\1/')"
[ -z "$file" ] && exit 0
[ -f "$file" ] || exit 0

# Optional glob filter (e.g. "*.go") — skip files that don't match.
if [ -n "${FORMAT_PATHS:-}" ]; then
  case "$file" in $FORMAT_PATHS) ;; *) exit 0 ;; esac
fi

( cd "$ROOT" && eval "$FORMAT_CMD \"$file\"" ) >/dev/null 2>&1 || true
exit 0
