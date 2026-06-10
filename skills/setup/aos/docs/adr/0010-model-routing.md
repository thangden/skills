# 0010 — Model routing: per-skill tiers now; eval-gated cascade deferred (needs an eval harness)

aos v2.1 set a fixed model per skill — curator = sonnet (classification accuracy), janitor + feature-evaluator = haiku (cheap scans). The franchise direction (N2) is provider-agnostic and "cheapest model that passes eval", i.e. a Haiku → Sonnet → Opus cascade.

For v2.2 we ship the routing POLICY, not a runtime cascade. Per-skill/agent model is declarative (frontmatter `model:`), tuned to task difficulty: classification / extraction → small (haiku); drafting / review → mid (sonnet); novel or long-horizon reasoning → large (opus). Opportunistic escalation is allowed where a signal exists — a skill may re-run on the next tier when the model self-reports low confidence or a verification check fails — but this is heuristic, not systematic.

A true "cheapest-that-passes-eval" cascade is deferred, and the reason is concrete: it requires an EVAL HARNESS — a representative, machine-scored eval per task — to decide when a cheaper model actually "passes". aos has no eval framework for a user's own tasks, and a cascade without eval is guesswork (it would escalate or stop arbitrarily). Per-use-case evals can't live in a generic template, so we document the policy now and add the cascade when an eval harness exists (likely alongside the C-broad observability work).

Provider-agnosticism is independent and already holds: model IDs and providers are swappable via frontmatter plus the provider abstraction mirrored from pilot-chatbot. This ADR adds no vendor lock-in.
