# 0002 — Entry Schema and Tracker Separation

**Context.** aos v1 stored three fixed buckets under `.claude/memory/`: `system-knowledge.md` (long-lived facts), `active-context.md` (sprint tracker), and `episodic/YYYY-MM-DD.md` (per-day log). User Memory under `~/.claude/projects/<repo-hash>/memory/` is harness-managed and uses Anthropic's 4-type frontmatter schema (`user | feedback | project | reference`). For aos v2 we had to pick a single canonical Entry shape across both Memory locations and decide where the sprint tracker belongs.

**Decision.** Every Memory Entry — Workspace or User — uses the Anthropic 4-type schema: `type: user | feedback | project | reference`, one file per Entry, YAML frontmatter (`name`, `description`, `type`, optional fields) plus markdown body. The sprint tracker is moved out of the Memory layer to `.claude/active-context.md` (sibling of `.claude/memory/`, still git-committed). Janitor does not scan the tracker; the Memory Guard hook checks tracker freshness separately. Team/business facts that do not cleanly map to `user`, `feedback`, or `reference` are filed as `type: project` (Aha is the project context for an Aha employee).

**Why.** Anthropic's 4-type taxonomy is mandatory for User Memory and matures with the platform; reusing it in Workspace Memory gives one Curator decision matrix, one Janitor scanner, and one mental model for users. The Anthropic system prompt explicitly excludes ephemeral state — *"in-progress work, temporary state, current conversation context"* — from memory; the sprint tracker is exactly that. Treating it as a Memory Entry caused Janitor false positives in v1 (the tracker is mutable by design, Janitor flagged it stale every scan). Separation removes that noise and keeps the conceptual line clean: **Memory = knowledge, Tracker = state**.

**Considered options.**

- α 4-type uniform + tracker outside Memory — chosen.
- β 4-type uniform + tracker as `type: project` Entry inside Memory — rejected: re-introduces v1's Janitor false-positive class.
- γ aos v1 buckets in Workspace Memory, 4-type only in User Memory — rejected: two schemas means two Curator paths, two Janitor scanners, two migration scripts, and confused users.

**Consequences.**

- Migration v1 → v2 is no longer no-op: `system-knowledge.md` must be split per-heading into individual Entries (each gets `type: project`, `scope: team`); `episodic/YYYY-MM-DD.md` files become single Entries `type: project, scope: team` with the date preserved in the `name` field; `active-context.md` is moved to `.claude/active-context.md`. CLAUDE.md references must be updated.
- Memory Guard hook splits into two checks: (1) Memory Entry write recency in either Workspace or User Memory, (2) tracker file recency at `.claude/active-context.md`.
- Workspace Memory may extend the type vocabulary with custom types (e.g. `domain`) if 4-type proves too tight in practice — the Anthropic harness never reads Workspace Memory so custom types are non-breaking. C-narrow ships 4-type only; any extension is its own ADR.
- Aha employees without external trackers (Jira/Linear) keep `.claude/active-context.md` as their primary tracker. Path changes, function does not.
