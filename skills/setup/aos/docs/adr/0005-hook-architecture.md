# 0005 — Two hooks (Stop and SessionStart), warn only; schema validation is the only block

aos v1 shipped one Stop hook that blocked (exit 2) whenever `.claude/memory/` had no file modified in the last 30 minutes. The block forced users into anti-patterns — touching a memory file just to escape the gate, rather than saving anything meaningful — and missed the larger v2 surface: Janitor delta runs, Tracker freshness, pending report visibility across sessions. Curator now auto-saves on confidence (ADR-0003) and Janitor wants an auto-delta on Stop plus a way to surface pending reports at the next session (ADR-0004).

aos v2 generates two hook scripts wired to two Claude Code hook types.

The Stop hook at `.claude/hooks/memory-stop.sh` detects Curator activity via a marker file (`.claude/.curator-active`, written by Curator on every save and removed by the hook after). If the marker is present, the hook invokes `.claude/hooks/janitor-delta.sh` for a lightweight scan over Entries just written and their neighbors. It also warns to stderr if `.claude/active-context.md` is older than 14 days. In all normal paths, exit code is 0.

The SessionStart hook at `.claude/hooks/janitor-surface.sh` scans for the most recent `.claude/janitor-report-*.md` and checks the `.claude/.janitor-applied` marker. If a report exists and hasn't been applied, it prints a one-line stderr warning surfacing the pending Conflict count and the `/clean-memory` command. It never blocks.

There is exactly one hard-fail path. If Curator writes an Entry that fails frontmatter schema validation — missing `name`, `description`, `type`, or `scope` — the Stop hook exits 2 with a fix-instruction message. That's a hard error, not a behavior nudge.

The Tech and Non-Tech hook variants from aos v1 remain. They differ only in additive git-aware checks (secret detection in staged diff, `.env` guard); the architecture is identical.

Blocking on no-memory-write in v1 lost user trust because most sessions legitimately have nothing to save — short Q&A, exploration, debugging. Users learned to circumvent rather than comply. The new split separates two concerns: Stop acts on this session, SessionStart surfaces work from the last one. Auto-delta on Stop catches Conflict and Duplicate while context is fresh; SessionStart makes pending reports visible without asking the user to remember they exist. Warn-only is the correct nudge for behavior change — repeated visibility builds the habit without breaking flow. Blocking stays reserved for cases where continuing would corrupt state.

Single-Stop-with-everything was tempting but overloads one script and gives nothing for cross-session surfacing. Adding SubagentStop is deferred to C-broad, when Curator and Janitor migrate from Skill to Agent for context isolation — until then, SubagentStop adds plumbing without functional gain. UserPromptSubmit was rejected for trigger-keyword detection; hard-coding `ghi nhớ` / `remember` / etc. in bash misses too much nuance that Claude's reasoning handles better.

`.claude/.curator-active` and `.claude/.janitor-applied` are reserved marker names — aos must add them to the workspace `.gitignore`. SessionStart requires a recent Claude Code; if absent, a CLAUDE.md preamble instruction is the graceful fallback. Curator's contract is to write the marker before announcing completion. Janitor's `--apply` writes `.janitor-applied` on success, and the SessionStart hook treats marker-newer-than-report as applied. Delta scan adds Stop latency in active sessions — acceptable for C-narrow, with async fire-and-forget queued as mitigation. The 14-day tracker threshold is a knob, retunable without ADR.
