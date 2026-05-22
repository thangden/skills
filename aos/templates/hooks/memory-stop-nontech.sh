#!/bin/bash
# aos v2 Stop hook — Non-Tech variant
# Identical to memory-stop.sh except git-aware secret + .env guards are skipped.
# Authority: aos/docs/adr/0005-hook-architecture.md
# Behavior: warn-only (exit 0) except on hard schema-validation failure

set -u
ERRORS=0
WORKSPACE_ROOT="$(pwd)"

# ---- 1. Curator activity → Janitor delta ----
MARKER="${WORKSPACE_ROOT}/.claude/.curator-active"
if [ -f "$MARKER" ]; then
  echo "[memory-stop] Curator active this session — running Janitor delta scan..." >&2
  if [ -x "${WORKSPACE_ROOT}/.claude/hooks/janitor-delta.sh" ]; then
    bash "${WORKSPACE_ROOT}/.claude/hooks/janitor-delta.sh" || echo "[memory-stop] Janitor delta exited non-zero (non-fatal)" >&2
  else
    echo "[memory-stop] janitor-delta.sh missing or not executable — skipping delta scan" >&2
  fi
  rm -f "$MARKER"
fi

# ---- 2. Tracker freshness (warn-only) ----
TRACKER="${WORKSPACE_ROOT}/.claude/active-context.md"
if [ -f "$TRACKER" ]; then
  if MTIME=$(stat -f %m "$TRACKER" 2>/dev/null); then
    :
  elif MTIME=$(stat -c %Y "$TRACKER" 2>/dev/null); then
    :
  else
    MTIME=""
  fi
  if [ -n "$MTIME" ]; then
    AGE_DAYS=$(( ( $(date +%s) - MTIME ) / 86400 ))
    if [ "$AGE_DAYS" -gt 14 ]; then
      echo "[memory-stop] Tracker .claude/active-context.md not updated for $AGE_DAYS days — review In Progress / To Do" >&2
    fi
  fi
fi

# ---- 3. Memory Entry schema validation (HARD ERROR — only block path) ----
MEMORY_DIR="${WORKSPACE_ROOT}/.claude/memory"
if [ -d "$MEMORY_DIR" ]; then
  for f in "$MEMORY_DIR"/*.md; do
    [ -e "$f" ] || continue
    base="$(basename "$f")"
    case "$base" in
      MEMORY.md) continue ;;
      _archive*) continue ;;
    esac
    head -n 12 "$f" | grep -q "^name:" || { echo "[memory-stop] SCHEMA: $f missing 'name'" >&2; ERRORS=1; }
    head -n 12 "$f" | grep -q "^description:" || { echo "[memory-stop] SCHEMA: $f missing 'description'" >&2; ERRORS=1; }
    head -n 12 "$f" | grep -q "^type:" || { echo "[memory-stop] SCHEMA: $f missing 'type'" >&2; ERRORS=1; }
    head -n 12 "$f" | grep -q "^scope:" || { echo "[memory-stop] SCHEMA: $f missing 'scope'" >&2; ERRORS=1; }
  done
fi

# Non-Tech variant: no git-aware secret/.env guards (assumes no git)

if [ "$ERRORS" -eq 1 ]; then
  echo "[memory-stop] Hard error detected — fix and retry" >&2
  exit 2
fi
exit 0
