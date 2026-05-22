# 0005 — Hook Architecture: Stop + SessionStart, Warn-Only

**Context.** aos v1 shipped a single Stop hook that blocked (exit code 2) when `.claude/memory/` had no file modified in the last 30 minutes. The block forced users into anti-patterns — touching a memory file to escape the gate rather than saving anything meaningful — and missed the larger v2 surface: Janitor delta runs, Tracker freshness, pending report visibility across sessions. Curator (ADR-0003) now auto-saves on confidence; Janitor (ADR-0004) wants an auto-delta on Stop and a way to surface pending reports at the next session.

**Decision.** aos v2 generates two hook scripts wired to two Claude Code hook types:

- **Stop hook** (`.claude/hooks/memory-stop.sh`).
  - Detects Curator activity via marker file `.claude/.curator-active` (Curator touches it on every save; the hook removes it after).
  - If marker present, invokes `.claude/hooks/janitor-delta.sh` for a lightweight Conflict + Duplicate scan over the Entries just written and their neighbors.
  - Warns (stderr only, exit 0) if `.claude/active-context.md` is older than 14 days.
  - **Never blocks.** Exit code is 0 in all normal paths.
- **SessionStart hook** (`.claude/hooks/janitor-surface.sh`).
  - Scans `.claude/janitor-report-*.md` for the latest report and checks for `.claude/.janitor-applied` marker.
  - If a report exists and was not applied, prints a one-line warning to stderr surfacing the count of pending Conflicts and the `/clean-memory` command to review.
  - Never blocks.
- **Blocking exception.** Only one hard-fail path exists: if Curator writes an Entry that fails frontmatter schema validation (missing `name`, `description`, `type`, `scope`), the Stop hook exits 2 with a fix-instruction message. This is a hard error, not a behavior nudge.

Tech and Non-Tech variants of the Stop hook remain (per aos v1), differing only in additive git-aware checks (secret detection in staged diff, `.env` guard). The hook architecture is identical.

**Why.** The v1 block-on-no-memory-write hook lost user trust because most sessions legitimately have nothing to save (short Q&A, exploration, debugging). Blocking pushed users to circumvent rather than comply. The new design separates two concerns: Stop = act-on-this-session, SessionStart = surface-pending-from-last-session. Auto-delta on Stop catches the Conflict/Duplicate class while context is fresh (ADR-0004); SessionStart makes pending reports visible without requiring the user to remember they exist. Warn-only is the correct nudge mechanism for behavior change — repeated visibility builds the habit without breaking flow. Blocking is reserved for hard errors (schema invalid) where continuing would corrupt state.

**Considered options.**

- α Single Stop hook, expanded scope — rejected: overloads Stop, no cross-session surface for pending reports.
- β Stop + SessionStart, warn-only — chosen.
- γ Stop + SessionStart + SubagentStop — deferred to C-broad when Curator and Janitor migrate from Skill to Agent for context isolation.
- δ UserPromptSubmit + Stop — rejected: hard-codes trigger keywords in bash, misses VN/EN/mixed nuance; Claude reasoning does it better.

**Consequences.**

- `.claude/.curator-active` and `.claude/.janitor-applied` are reserved marker filenames. aos generation must add them to `.gitignore`.
- SessionStart hook is a Claude Code feature; aos generation must verify the harness version supports it. If not, fall back to a CLAUDE.md preamble instruction (less reliable but degrades gracefully).
- Curator implementation contract: on every save, write the marker file before announcing completion.
- Janitor `--apply` implementation contract: on success, write `.claude/.janitor-applied` with timestamp; the SessionStart hook treats marker-newer-than-report as "applied".
- Stop hook latency increases by the Janitor delta runtime when Curator was active. C-narrow accepts this; fire-and-forget async write is the planned mitigation if user feedback flags it.
- Tracker freshness threshold (14 days) is a knob, not architecture. Retunable without ADR.
