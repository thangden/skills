#!/usr/bin/env bash
# aos verify-gate — language-agnostic code-verification gate (ADR-0008).
# Registered on the Stop hook. Reads .claude/hooks/config.env and runs up to
# three layers: L1 compile/static, L2 unit/integration, L3 E2E (opt-in).
#
# VERIFY_GATE_MODE: block (exit 2 on failure) | warn (stderr only) | off (skip).
# Portable: bash + POSIX only. NO language assumptions — every command comes
# from config.env, so the same script serves TS / Go / Python / anything.
set -u

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
CFG="$ROOT/.claude/hooks/config.env"
[ -f "$CFG" ] || exit 0          # no config → nothing to verify
# shellcheck disable=SC1090
. "$CFG"

MODE="${VERIFY_GATE_MODE:-off}"
[ "$MODE" = "off" ] && exit 0

AUDIT="$ROOT/.claude/hooks-audit-$(date +%Y-%m-%d).log"
FAILED=""

run_layer() {            # $1 = label, $2 = command
  [ -z "${2:-}" ] && return 0
  local out rc
  out="$( cd "$ROOT" && eval "$2" 2>&1 )"; rc=$?
  if [ "${AUDIT_LOG:-0}" = "1" ]; then
    printf '{"ts":"%s","hook":"verify-gate","layer":"%s","rc":%d}\n' \
      "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$1" "$rc" >> "$AUDIT" 2>/dev/null || true
  fi
  [ $rc -ne 0 ] && FAILED="${FAILED}
[$1] FAILED — \`$2\`
$(printf '%s' "$out" | tail -n 20)
"
}

run_layer "L1:compile" "${COMPILE_CMD:-}"
run_layer "L1:lint"    "${LINT_CMD:-}"
run_layer "L2:test"    "${TEST_CMD:-}"
[ "${E2E_ON_STOP:-0}" = "1" ] && run_layer "L3:e2e" "${E2E_CMD:-}"

# OTel GenAI span (gated, best-effort, fail-silent — hardens later with a real SDK)
if [ "${OTEL_ENABLED:-0}" = "1" ] && [ -n "${OTEL_ENDPOINT:-}" ] && command -v openssl >/dev/null 2>&1; then
  _tid="$(openssl rand -hex 16)"; _sid="$(openssl rand -hex 8)"; _now="$(date +%s)000000000"
  _failed=false; [ -n "$FAILED" ] && _failed=true
  curl -sf -m 3 "$OTEL_ENDPOINT/v1/traces" -H 'Content-Type: application/json' -d \
    "{\"resourceSpans\":[{\"resource\":{\"attributes\":[{\"key\":\"service.name\",\"value\":{\"stringValue\":\"aos\"}}]},\"scopeSpans\":[{\"spans\":[{\"traceId\":\"$_tid\",\"spanId\":\"$_sid\",\"name\":\"aos.verify-gate\",\"kind\":1,\"startTimeUnixNano\":\"$_now\",\"endTimeUnixNano\":\"$_now\",\"attributes\":[{\"key\":\"verify.failed\",\"value\":{\"boolValue\":$_failed}}]}]}]}]}" \
    >/dev/null 2>&1 || true
fi

[ -z "$FAILED" ] && exit 0

# Teacher's-red-pen output: what failed + the exact command to reproduce/fix.
{
  echo "──────── aos verify-gate: verification failed ────────"
  printf '%s\n' "$FAILED"
  echo "Fix the above before finishing. To downgrade to warnings, set"
  echo "VERIFY_GATE_MODE=warn in .claude/hooks/config.env."
} >&2

[ "$MODE" = "block" ] && exit 2  # block the Stop
exit 0                           # warn mode: surfaced, not blocked
