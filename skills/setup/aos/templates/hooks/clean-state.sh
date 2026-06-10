#!/usr/bin/env bash
# aos clean-state exit gate (Stop) — warn-only, never blocks. Covers the artifact/temp
# dimensions of the harness-engineering clean-state checklist (L12). Build + test are the
# verify-gate's job; Tracker freshness is memory-stop's. This nudges on leftovers.
set -u
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
warn=0

# Temp / backup files left in the tree
tmp=$(cd "$ROOT" 2>/dev/null && git status --porcelain 2>/dev/null | awk '{print $2}' | grep -Ei '\.(tmp|bak|orig|swp)$' | head -3)
[ -n "$tmp" ] && { echo "  [clean-state] temp/backup files: $(echo "$tmp" | tr '\n' ' ')" >&2; warn=$((warn + 1)); }

# Debug / TODO markers added in staged changes
dbg=$(cd "$ROOT" 2>/dev/null && git diff --cached 2>/dev/null | grep -E '^\+' | grep -Ec '(console\.log|debugger|fmt\.Println\(|TODO|FIXME|XXX)')
[ "${dbg:-0}" -gt 0 ] && { echo "  [clean-state] staged changes add ${dbg} debug/TODO marker line(s)" >&2; warn=$((warn + 1)); }

[ "$warn" -gt 0 ] && echo "[clean-state] ${warn} item(s) to tidy before ending the session (build/test: 'make check')." >&2
exit 0
