#!/bin/bash
# aos v2 Stop hook — Memory Guard + Janitor delta trigger + Tracker freshness
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
  # macOS stat: -f %m; Linux stat: -c %Y. Try macOS first.
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
# Validate every Entry in .claude/memory/ has required frontmatter: name, description, type, scope
MEMORY_DIR="${WORKSPACE_ROOT}/.claude/memory"
if [ -d "$MEMORY_DIR" ]; then
  for f in "$MEMORY_DIR"/*.md; do
    [ -e "$f" ] || continue
    base="$(basename "$f")"
    # Skip non-Entry files
    case "$base" in
      MEMORY.md) continue ;;
      _archive*) continue ;;
    esac
    # Check the first 12 lines contain frontmatter with required fields
    head -n 12 "$f" | grep -q "^name:" || { echo "[memory-stop] SCHEMA: $f missing 'name'" >&2; ERRORS=1; }
    head -n 12 "$f" | grep -q "^description:" || { echo "[memory-stop] SCHEMA: $f missing 'description'" >&2; ERRORS=1; }
    head -n 12 "$f" | grep -q "^type:" || { echo "[memory-stop] SCHEMA: $f missing 'type'" >&2; ERRORS=1; }
    head -n 12 "$f" | grep -q "^scope:" || { echo "[memory-stop] SCHEMA: $f missing 'scope'" >&2; ERRORS=1; }
  done
fi

# ---- 4. Tech variant — git-aware secret + .env guards (only if git repo) ----
if git rev-parse --git-dir > /dev/null 2>&1; then
  if git diff --cached 2>/dev/null | grep '^\+' | grep -v '^\+\+\+' \
     | grep -iE "(password|secret|api[_-]?key|token)\s*=\s*['\"][^'\"]{8,}" > /dev/null 2>&1; then
    echo "[memory-stop] BLOCKED: Hardcoded secret detected in staged changes" >&2
    ERRORS=1
  fi
  if git diff --cached --name-only 2>/dev/null | grep -E '(^|/)\.env$' > /dev/null 2>&1; then
    echo "[memory-stop] BLOCKED: .env file staged — do not commit credentials" >&2
    ERRORS=1
  fi
fi

# ---- Exit ----
if [ "$ERRORS" -eq 1 ]; then
  echo "[memory-stop] Hard error detected — fix and retry" >&2
  exit 2
fi
exit 0
