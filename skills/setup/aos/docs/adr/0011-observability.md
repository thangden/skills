# 0011 — Observability: structured audit log by default, OTel emit gated, full tracing deferred to a collector

aos v2.1 added a per-run audit log (JSONL at `.claude/hooks-audit-*.log`) and a gated OTel span emit in verify-gate (`OTEL_ENABLED` + `OTEL_ENDPOINT`). This records the approach and its boundary, so the harness has the observability layer the harness-engineering doc calls for without assuming infrastructure.

The always-on, zero-infra layer is the audit-log JSONL. It is collector-agnostic (just a log file), git-ignored, and ingestable by any OTel filelog receiver or log pipeline the team already runs. OTel push (OTLP/HTTP span) is OFF by default and best-effort / fail-silent when ON; it emits minimal spans (openssl-generated ids) as a convenience, not a guarantee.

Full, validated OTel tracing — proper trace-context propagation, parent/child spans across the agent loop, tested end-to-end — is deferred because it requires a running collector to test against and a real OTel SDK rather than hand-rolled curl. That is infrastructure a generic template can't assume. The audit log gives the team observability today; harden to a real SDK + collector when that infra exists.

Langfuse is intentionally out of scope here: LLM-call observability (prompt versioning, per-call cost/latency, evals) belongs to the PRODUCT runtime — e.g. AhaPilot / pilot-chatbot, which already integrates Langfuse — not to the aos dev-harness. aos observes the dev/coding loop (hooks, gates); the product observes its own model calls.
