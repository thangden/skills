# 0003 — Curator Trigger Model and Confidence-Driven Routing

**Context.** aos v1 Curator was invoked only via `@memory-curator` or `/curate` and always asked the user to classify before saving. Field tests showed the majority of Non-Tech users do not reliably remember skill names; explicit-only triggering produced near-zero usage in v1. Meanwhile, Anthropic's own auto-memory pattern has Claude proactively decide what to save without a user command. For aos v2 we had to decide how Curator gets invoked and how aggressive its routing should be.

**Decision.** Curator uses a hybrid trigger and confidence-driven routing:

- **Trigger.** Both implicit and explicit. Implicit: Claude monitors for memory-worthy signals — explicit cues (`ghi nhớ`, `remember`, `from now on`, `đừng X anymore`) and content-shape signals (user states a durable fact, a preference, a workflow rule, an external pointer) — and invokes Curator inline. Explicit: user can still type `@curator` or `/curate <info>` to force routing.
- **Routing.** Curator infers `scope` and `type` from context and assigns a confidence score. At `confidence >= 0.8` it auto-saves and announces the destination, scope, type, and a one-line override path. Below `0.8` it asks exactly one targeted question (the dimension it is least sure about — usually scope or type, never both) and saves on the answer.
- **Reversal.** Every save announces the path. The user can reply `no` or `override scope=personal` to relocate. Curator logs all auto-saves to the day's episodic Entry so reversals are traceable.

**Why.** The hybrid keeps the common-case zero-friction (matching Anthropic's pattern) while preserving control where Curator is genuinely uncertain. Explicit-only triggering failed in v1; implicit-only routing without confidence gating would either ask too often (annoy) or save silently (lose control). Confidence-driven gating exits the binary trade-off: high-signal saves move fast, low-signal saves ask once. Announcing every destination makes the system legible — the user always knows where their words went and can fix mistakes immediately.

**Considered options.**

- α Explicit-only + always interview — rejected: matches v1, proven to kill usage.
- β Explicit-only + auto-infer + announce — rejected: still requires user to remember the command; loses implicit signal capture.
- γ Implicit-only + auto-infer + announce — rejected: no user-side knob to force routing when needed; harder to test/debug.
- δ Hybrid trigger + confidence-driven interview — chosen.

**Consequences.**

- Curator SKILL.md description must list trigger cues explicitly so Claude reliably invokes it. Tested triggers go in `evals/curator-triggers.md` (created when first eval is written).
- The `0.8` confidence threshold is a calibration knob, not an architectural commitment. Expect to retune after 2-4 weeks of real use. No ADR needed for retuning.
- Curator must emit a structured announcement (`saved: <path>` + `scope:` + `type:` + `confidence:`) so downstream tools (Janitor, hook, future Promoter) can parse and audit.
- Implicit triggering risks false-positive saves during casual conversation. Mitigation: confidence gating + episodic logging + one-word rollback. If false-positive rate exceeds tolerance in calibration, fall back to explicit-only as a per-Workspace setting (`CLAUDE.md` flag), not a re-architecture.
- Janitor must learn to read Curator's confidence log when flagging Duplicates (low-confidence auto-saves are first suspects).
