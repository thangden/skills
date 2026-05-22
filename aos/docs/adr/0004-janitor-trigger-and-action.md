# 0004 — Janitor Trigger Model and Action Policy

**Context.** aos v1 Janitor ran only when the user explicitly invoked `@janitor` or `/clean-memory`, and produced report-only output (the user had to edit files manually to act on suggestions). The result was the same as Curator v1: near-zero usage, because Non-Tech employees do not remember to clean memory and editing five files by hand is friction enough to skip. v2 Curator now auto-saves more aggressively (ADR-0003), so without a parallel upgrade Janitor will fall further behind the write rate.

**Decision.** Janitor uses a dual-trigger, two-step action model:

- **Triggers.**
  - Manual: `@janitor` or `/clean-memory` runs a full scan of all active Memory locations (two in C-narrow, three in C-broad).
  - Auto-delta on Stop: when the Stop hook fires AND Curator wrote at least one Entry this session, Janitor runs a lightweight delta scan limited to (a) the Entries just written and (b) neighbors sharing topic by filename prefix or `name`/`type` frontmatter match. Only Conflict and Duplicate categories are checked in delta mode (Stale and Bloat require full scan).
- **Action policy.**
  - Both triggers produce a report file at `.claude/janitor-report-YYYY-MM-DD.md`.
  - Janitor never auto-deletes. User reviews the report and runs `/clean-memory --apply` to execute the batch (merge Duplicates, archive Stale into `.claude/memory/_archive/`, resolve Conflicts per user-marked decisions). Per-item opt-out via `/clean-memory --apply --skip <item-id>`.
  - "Archive" means file move into `_archive/`, not delete — restoration is `mv` away.

**Why.** Auto-delta on Stop catches the most expensive class of memory error — a fresh write that contradicts an existing Entry — while the context is still fresh in the user's head and Curator's announcement is still on screen. Waiting for manual full scan (v1) meant conflicts were typically found 30-90 days later, after working on bad data. The lightweight delta is cheap (small set, no embeddings needed — filename prefix + frontmatter `name`/`type` is enough); only manual triggers full O(N) scan. Two-step apply preserves user control over data destruction without forcing manual file editing, which is what killed v1 cleanup throughput.

**Considered options.**

- α Manual full scan + report-only — rejected: v1 status quo, proven low usage.
- β Manual + auto-delta-on-Stop + report-only — rejected: catches issues, but user still has to edit files to act.
- γ Manual + auto-delta-on-Stop + report-with-batch-apply — chosen.
- δ Manual + scheduled weekly cron + auto-prune low-risk + report rest — rejected: cron infra is plugin-level (C-broad); auto-prune has data-loss risk; defer to a future ADR after C-broad ships.

**Consequences.**

- Stop hook gains a Curator-active check (marker file or session log — design in hook ADR).
- `.claude/memory/_archive/` becomes a reserved directory; Curator, Janitor, and Migration must not treat archived Entries as live Memory.
- Apply step needs a state file recording what was archived/merged in each batch so `--skip` can be re-applied across `--apply` runs.
- Delta scan latency adds to Stop hook runtime. Acceptable for C-narrow; if user complains, fire-and-forget pattern (write report async, surface at next SessionStart) is the planned mitigation.
- Janitor must read Curator's confidence log (per ADR-0003) — low-confidence auto-saves are first candidates when flagging Duplicates.
