# 0001 — Memory Scope Routing: Hybrid 3-tier

**Context.** aos v1 stored everything under `.claude/memory/` (Workspace Memory) and ignored Anthropic's harness-managed `~/.claude/projects/<repo-hash>/memory/` (User Memory). For aos v2, we had to decide whether Workspace and User memory coexist, and how Entries are routed between them.

**Decision.** Every Memory Entry carries a `scope` field. In C-narrow, two values ship: `team` → Workspace Memory (git-committed, team-shared) and `personal` → User Memory (harness-managed, auto-loaded per Workspace). Curator default is `team`; `personal` requires explicit signal. C-broad adds a third value `global` → User Global Memory (`~/.claude/memory/`); it ships only after ADR-0003 (loader mechanism) and ADR-0004 (Promoter sanitization) are accepted.

**Why.** Workspace-only forfeits the Anthropic auto-load benefit and gives no path to cross-Workspace knowledge sharing. User-only is not git-committed, so 200 Ahamove employees cannot share team knowledge through it. The 2-Scope hybrid matches the immediate taxonomy of what users save — team facts vs personal preferences — and makes the future `global` Scope a strict superset: Promoter just changes `scope` from `team` to `global` and moves the file. No re-architecture between phases. `global` is deferred because `~/.claude/memory/` has no native Anthropic auto-loader — designing and shipping a custom loader, plus the cross-Workspace leak threat-model, belongs in C-broad with its own ADRs.

**Considered options.**

- α Workspace-only — rejected: bypasses platform features, no cross-Workspace path.
- β User-only — rejected: not git-committed, breaks team-shareability.
- γ Hybrid with `scope` tag, 2 values in C-narrow + 1 deferred to C-broad — chosen.
- γ' Hybrid shipping all 3 Scopes in C-narrow — rejected: requires loader + leak threat-model in C-narrow, violating the C-narrow scope-cap.

**Consequences.**

- Curator gains a 2-way routing decision in C-narrow (3-way in C-broad); default-to-`team` keeps the common case one-click.
- Janitor scans two locations in C-narrow, three in C-broad.
- Migration v1 → v2 tags every existing Entry `scope: team` and is otherwise a no-op.
- User Global Memory location (`~/.claude/memory/`) is not created in C-narrow; aos must not assume it exists.
- C-broad blockers recorded as TBD ADRs: User Global Memory loader, and Promoter sanitization + cross-Workspace leak policy. Numbers assigned when written.
