#!/usr/bin/env bash
# aos cold-start check (SessionStart) — confirms a fresh session can orient from the
# repo alone (the Cold-Start Test). Warn-only; never blocks. See COLD-START.md.
set -u
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

miss=0
need() { [ -e "$ROOT/$1" ] || { echo "  [cold-start] missing: $1" >&2; miss=$((miss + 1)); }; }

# The 5 cold-start questions map to these artifacts:
need "CLAUDE.md"                    # what is this / how organized
need ".claude/memory/MEMORY.md"     # working knowledge index
need ".claude/active-context.md"    # current progress (Tracker)
# how to run / verify: config.env (Tech) documents the commands
if [ -f "$ROOT/.claude/hooks/config.env" ]; then
  grep -qE '^(COMPILE_CMD|TEST_CMD)=".+"' "$ROOT/.claude/hooks/config.env" 2>/dev/null \
    || echo "  [cold-start] config.env present but no COMPILE_CMD/TEST_CMD set (how-to-verify undocumented)" >&2
fi

[ "$miss" -gt 0 ] && echo "[cold-start] $miss core file(s) missing — a fresh session may not orient cleanly. See COLD-START.md." >&2
exit 0
