# 0007 — Migration v1 → v2: Explicit Upgrade with Backup Folder

**Context.** aos v2 changes the on-disk layout significantly: Memory shifts from three fixed buckets to one-Entry-per-file 4-type schema (ADR-0002), the tracker moves out of `.claude/memory/` (ADR-0002), hooks change (ADR-0005), Curator and Janitor skills are added (ADR-0003, ADR-0004), and a version marker `.claude/aos-version` is introduced. v1 workspaces — including this skills-repo and ~50 Ahamove workshop submissions — cannot use v2 features without transformation. We had to decide how the upgrade is triggered and how it is reversed.

**Decision.** Migration is invoked **explicitly** via `/aos --upgrade`. aos does not auto-prompt when `/aos` runs in its normal mode (Phase 0 detection gate handles new-vs-existing — see SKILL.md Phase 0B). Rollback is provided via a **backup folder** at `.claude/_v1-backup-YYYYMMDD/` created before any transformation. `/aos --rollback` restores from the backup. Git stash is not used because aos must work on non-git workspaces (84% of Ahamove employees are Non-Tech and may not have initialized git).

**Why.** Explicit invocation eliminates a class of false-positive upgrades — clone a workspace, run `/aos` to bootstrap a new project, aos detects partial v1 shape from clone artifacts, prompts for upgrade the user didn't want. Forcing an explicit `--upgrade` flag makes intent unambiguous and is one extra word for the rare case where upgrade is genuinely desired. Backup folder is universal (works without git), atomic (one `cp -r` step), and human-inspectable (user can diff the backup against current state). The disk cost is negligible (Memory totals a few MB at most). The alternative of "side-by-side" two layouts was rejected because Janitor would scan both, surface false conflicts, and confuse users about which is live.

**Considered options.**

For trigger (10a):

- α No migration — rejected: abandons every v1 workspace including the skills-repo this design was developed in.
- β Auto-detect + prompt on regular `/aos` — rejected: false-positive risk when partial v1 shape exists in cloned workspaces.
- γ Explicit `/aos --upgrade` — chosen.
- δ Side-by-side parallel structures — rejected: dual Janitor scan, false conflicts, ambiguity about which is active.

For reversibility (10b):

- 1 Backup folder — chosen.
- 2 Git stash — rejected: 84% Non-Tech audience may not have git initialized; partial coverage.
- 3 No rollback — rejected: migration is too invasive (file moves, schema changes, hook script replacements) to ship without a safety net.

**Migration steps (executed by `/aos --upgrade` after user confirms dry-run preview).**

1. Pre-check: `.claude/` exists AND `.claude/aos-version` is absent. Abort otherwise.
2. Backup: `cp -r .claude .claude/_v1-backup-YYYYMMDD/`.
3. Split `.claude/memory/system-knowledge.md` by H2 headings; for each heading, write an Entry via Curator interview-mode (`type: project`, `scope: team`, filename slug from heading). If H2 split fails (no headings or malformed), fall back to one Entry `name: legacy-system-knowledge` and log a warning.
4. Move `.claude/memory/active-context.md` → `.claude/active-context.md`. Update any CLAUDE.md path references.
5. For each `.claude/memory/episodic/*.md`: add frontmatter (`type: project`, `scope: team`, `name: episodic-<date>`).
6. Generate `.claude/memory/MEMORY.md` index from all Entries.
7. Write `.claude/skills/curator.md` and `.claude/skills/janitor.md` from v2 templates.
8. Replace `.claude/hooks/quality-gate.sh` (v1) with `.claude/hooks/memory-stop.sh`, `.claude/hooks/janitor-surface.sh`, `.claude/hooks/janitor-delta.sh`.
9. Update `.claude/settings.json` to register Stop + SessionStart hooks.
10. Update CLAUDE.md, adding a section referencing Curator, Janitor, and the two Scopes.
11. Append today's episodic Entry: `Migrated workspace from aos v1 to v2 on YYYY-MM-DD`.
12. Write `.claude/aos-version` = `2.0.0`.

**Rollback (`/aos --rollback`).** Warn user any post-upgrade work in `.claude/` will be lost. On confirm: `rm -rf .claude/*` then `cp -r .claude/_v1-backup-*/. .claude/`.

**Consequences.**

- `.claude/_v1-backup-*/` becomes a reserved directory pattern. aos generation must add it to the Workspace `.gitignore`. Janitor must exclude it from scans.
- Migration is non-idempotent by design — running twice would re-snapshot the migrated state as if it were v1. The aos-version precheck prevents accidental double-run.
- H2-split fallback may produce a single legacy Entry that is large; Janitor's full scan will likely flag it for split — that is correct behavior and surfaces the cleanup work to the user.
- Migration is the planned validation path for Curator interview-mode (ADR-0006). The skills-repo itself will be the first migration target after aos v2 ships.
