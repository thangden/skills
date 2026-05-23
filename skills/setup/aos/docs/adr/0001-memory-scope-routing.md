# 0001 — Memory entries route by scope; C-narrow ships team and personal

aos v1 kept every memory file under `.claude/memory/` and never touched Anthropic's harness-managed `~/.claude/projects/<repo-hash>/memory/`. The two locations have opposite trade-offs: the repo-local one is git-committed and team-shareable but doesn't auto-load; the harness-managed one auto-loads per workspace but never crosses machines. aos v2 uses both, with a single `scope` field on every Memory Entry deciding where it lands.

In C-narrow, scope takes two values:

- `team` writes to `.claude/memory/` — git-committed Workspace Memory, the default for new entries.
- `personal` writes to `~/.claude/projects/<hash>/memory/` — harness-managed User Memory. Requires an explicit signal from the user.

A third value, `global`, would write to `~/.claude/memory/` (User Global Memory). It's deferred to C-broad because that path has no Anthropic auto-loader: shipping it means designing a custom loader plus a threat model for cross-Workspace knowledge leaks. Both belong in their own ADRs, not this one.

Workspace-only was rejected because it bypasses the platform's auto-load and offers no cross-Workspace path. User-only was rejected because it isn't git-committed, so a team can't share what they've collectively learned. Shipping all three scopes in C-narrow was rejected because the loader and leak policy are real design work — dragging them in would defeat the point of having a narrow first pass.

The 2-scope hybrid makes the future `global` scope a strict superset: when the Promoter ships, it just changes an Entry's `scope` from `team` to `global` and moves the file. No re-architecture between phases.

Curator routes between two locations now (three later), Janitor scans accordingly, and migration from v1 tags every existing Entry as `scope: team` and is otherwise a no-op.
