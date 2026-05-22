#!/bin/bash
# aos v2 helper — Janitor lightweight delta scan
# Called by memory-stop.sh when .curator-active marker is present
# Authority: aos/docs/adr/0004-janitor-trigger-and-action.md
#
# This script performs a placeholder structural check. The real semantic
# delta scan is performed by the Janitor skill (.claude/skills/janitor.md)
# when invoked by Claude — this script handles only the structural / file-
# system side that does not require Claude reasoning.

set -u
WORKSPACE_ROOT="$(pwd)"
MEMORY_DIR="${WORKSPACE_ROOT}/.claude/memory"
TODAY=$(date +%Y-%m-%d)
REPORT="${WORKSPACE_ROOT}/.claude/janitor-report-${TODAY}.md"

if [ ! -d "$MEMORY_DIR" ]; then
  exit 0
fi

# Find Entries modified in the last hour (proxy for "this session")
RECENT_ENTRIES=$(find "$MEMORY_DIR" -maxdepth 1 -name "*.md" -mmin -60 ! -name "MEMORY.md" 2>/dev/null)

if [ -z "$RECENT_ENTRIES" ]; then
  exit 0
fi

# Ensure report exists with header
if [ ! -f "$REPORT" ]; then
  cat > "$REPORT" <<EOF
# Janitor Report — ${TODAY}

Trigger: auto-delta (Stop hook)
EOF
fi

# Append delta section
{
  echo ""
  echo "## Delta scan — $(date +%H:%M:%S)"
  echo ""
  echo "Recent Entries (modified in last 60 minutes):"
  while IFS= read -r entry; do
    echo "- $(basename "$entry")"
  done <<< "$RECENT_ENTRIES"
  echo ""
  echo "_Semantic Conflict + Duplicate review requires running the Janitor skill_"
  echo "_via \`@janitor\` or \`/clean-memory\` to compare against neighbors._"
} >> "$REPORT"

echo "[janitor-delta] Appended delta section to $(basename "$REPORT")" >&2
exit 0
