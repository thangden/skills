#!/bin/bash
# aos v2 SessionStart hook — surface pending Janitor reports
# Authority: aos/docs/adr/0005-hook-architecture.md
# Behavior: warn-only (always exit 0)

set -u
WORKSPACE_ROOT="$(pwd)"
MEMORY_DIR="${WORKSPACE_ROOT}/.claude"

# Find the most recent Janitor report
LATEST_REPORT=$(ls -t "${MEMORY_DIR}"/janitor-report-*.md 2>/dev/null | head -1)
APPLIED_MARKER="${MEMORY_DIR}/.janitor-applied"

if [ -z "$LATEST_REPORT" ]; then
  exit 0
fi

# If applied marker is newer than the report, it has been processed
if [ -f "$APPLIED_MARKER" ]; then
  if [ "$APPLIED_MARKER" -nt "$LATEST_REPORT" ]; then
    exit 0
  fi
fi

# Surface a one-line warning with counts
CONFLICT_COUNT=$(grep -c "^## Conflict" "$LATEST_REPORT" 2>/dev/null || echo 0)
STALE_COUNT=$(grep -c "^## Stale" "$LATEST_REPORT" 2>/dev/null || echo 0)
BLOAT_COUNT=$(grep -c "^## Bloat" "$LATEST_REPORT" 2>/dev/null || echo 0)
DUPE_COUNT=$(grep -c "^## Duplicate" "$LATEST_REPORT" 2>/dev/null || echo 0)

echo "[janitor-surface] Pending Janitor report: $(basename "$LATEST_REPORT")" >&2
echo "[janitor-surface] Run /clean-memory to review, then /clean-memory --apply to act." >&2

exit 0
