# Migration Playbook: aos v1 → v2

Authority: [aos/docs/adr/0007-migration-v1-to-v2.md](../docs/adr/0007-migration-v1-to-v2.md)

This document is the step-by-step playbook Claude follows when invoked via `/aos --upgrade`. It is **not** an automated bash script — each step is a deliberate operation with user-visible output.

## Pre-flight checks

1. **Workspace is v1?** Check `.claude/` exists AND `.claude/aos-version` is absent.
   - If `.claude/` missing → not a v1 workspace; suggest `/aos` (fresh setup) instead. Abort.
   - If `.claude/aos-version` present → already upgraded to that version; abort with clear message.
2. **Backup name available?** Check `.claude/_v1-backup-YYYYMMDD/` (today's date) does not exist.
   - If exists → ask user whether to overwrite or append suffix `-N`.

## Dry-run preview

Before any file is touched, print the plan to the user:

```text
Migration plan (dry-run):

Backup:
  .claude/ → .claude/_v1-backup-YYYYMMDD/

Memory transformation:
  .claude/memory/system-knowledge.md (N lines) → split into M Entries
    [list each H2 heading found, with proposed filename slug]
  .claude/memory/active-context.md → .claude/active-context.md
  .claude/memory/episodic/*.md (K files) → reformatted with frontmatter

New files:
  .claude/memory/MEMORY.md (index)
  .claude/skills/curator.md  (from aos/templates/)
  .claude/skills/janitor.md
  .claude/hooks/memory-stop.sh
  .claude/hooks/janitor-surface.sh
  .claude/hooks/janitor-delta.sh
  .claude/settings.json (replaced)
  .claude/aos-version = 2.0.0

CLAUDE.md updates:
  - Add Memory Layer section referencing the two Scopes
  - Add Skill Routing pointing to Curator + Janitor

Proceed? (yes / no / show diff)
```

Wait for user confirmation. On `no` or anything not affirmative, abort. On `show diff`, render a unified diff preview and re-ask.

## Migration steps (on user `yes`)

### Step 1 — Backup

```bash
cp -r .claude .claude/_v1-backup-YYYYMMDD
```

The backup is a sibling inside `.claude/` rather than at repo root so it inherits the existing gitignore (`.claude/` is typically ignored or partially tracked). If repo policy requires backup outside `.claude/`, prompt the user for an alternate path.

### Step 2 — Split `system-knowledge.md`

Parse `.claude/memory/system-knowledge.md` by H2 (`## Heading`) and H3 (`### Subheading`) boundaries:

- For each H2 section, create an Entry at `.claude/memory/<slug>.md` where `<slug>` is the kebab-case of the heading text (≤40 chars).
- Frontmatter for each Entry:
  ```yaml
  ---
  name: <slug>
  description: <first sentence of section body, truncated to 120 chars>
  type: project
  scope: team
  ---
  ```
- Body: the section content verbatim, minus the original H2/H3 heading line.
- **Fallback:** if parse fails (no H2 headings, or malformed file), write one Entry `name: legacy-system-knowledge, type: project, scope: team` containing the entire file body. Log a WARNING and recommend the user run Janitor's Bloat detection later.

### Step 3 — Move Tracker

```bash
mv .claude/memory/active-context.md .claude/active-context.md
```

If a file already exists at the destination, prompt user: merge, overwrite, or rename target.

### Step 4 — Reformat episodic entries

For each file in `.claude/memory/episodic/` (matching pattern `YYYY-MM-DD.md`):

- Add frontmatter:
  ```yaml
  ---
  name: episodic-YYYY-MM-DD
  description: Daily log for YYYY-MM-DD
  type: project
  scope: team
  ---
  ```
- Move file from `.claude/memory/episodic/` to `.claude/memory/episodic-YYYY-MM-DD.md` (flatten the subfolder).
- After all moved, `rmdir .claude/memory/episodic` if empty.

### Step 5 — Generate `MEMORY.md` index

Enumerate all Entries in `.claude/memory/*.md` (excluding `MEMORY.md`, `_archive/`, `_v1-backup-*`). Group by `type` field. Write `.claude/memory/MEMORY.md` per the schema in [aos/templates/](../templates/) — one bullet per Entry with `[name](file.md) — first line of description`.

### Step 6 — Install Curator and Janitor

Copy `aos/templates/skills/curator.md` → `.claude/skills/curator.md`.
Copy `aos/templates/skills/janitor.md` → `.claude/skills/janitor.md`.

If `.claude/skills/memory-curator.md` or `.claude/skills/memory-janitor.md` exist (v1 names), move to `.claude/skills/_v1-deprecated/` (create folder if absent). Do not delete — the user may have customized.

### Step 7 — Replace hook scripts

Detect Tech vs Non-Tech variant from CLAUDE.md or by checking presence of git repo:

- Tech (git repo present): copy `aos/templates/hooks/memory-stop.sh` → `.claude/hooks/memory-stop.sh`.
- Non-Tech (no git repo OR CLAUDE.md indicates Non-Tech team): copy `aos/templates/hooks/memory-stop-nontech.sh` → `.claude/hooks/memory-stop.sh`.

Copy `aos/templates/hooks/janitor-surface.sh` and `janitor-delta.sh` to `.claude/hooks/` regardless of variant. Make all `.sh` files executable.

Move v1's `.claude/hooks/quality-gate.sh` (if present) to `.claude/hooks/_v1-deprecated/`.

### Step 8 — Replace `settings.json`

Copy `aos/templates/settings.json` → `.claude/settings.json`. If the existing `settings.json` has user customizations beyond hook registration, merge rather than replace — preserve `env`, `permissions`, etc.

### Step 9 — Update `CLAUDE.md`

Append (do not replace) the following sections if absent:

- `## Memory Layer` — describe the two Scopes (`team` / `personal`), reference Curator + Janitor
- `## Skill Routing` — point to `.claude/skills/` priority, list Curator + Janitor
- `## Operating Constraints` — reference Memory Guard warn-only behavior

If sections already exist with different wording, leave alone and surface as TODO in the user's Tracker.

### Step 10 — Write `aos-version`

```bash
echo "2.0.0" > .claude/aos-version
```

### Step 11 — Update `.gitignore`

Append (deduplicated):

```text
.claude/.curator-active
.claude/.janitor-applied
.claude/memory/_archive/
.claude/janitor-report-*.md
.claude/_v1-backup-*/
```

### Step 12 — Log to today's episodic Entry

Append to `.claude/memory/episodic-<today>.md` (create if absent with proper frontmatter):

```markdown
## YYYY-MM-DD HH:MM — Migration v1 → v2

Migrated workspace from aos v1 to v2. Backup at `.claude/_v1-backup-YYYYMMDD/`.
Steps completed: N. Warnings: <list any>. Run `/aos --rollback` to revert.
```

## Post-migration summary

Print to user:

```text
✓ Migrated to aos v2
  Backup: .claude/_v1-backup-YYYYMMDD/
  Entries created: N
  Warnings: <count>

Next:
  - Review .claude/memory/ — check the split is sensible
  - Open .claude/active-context.md — confirm Tracker location
  - Run `/clean-memory` for first Janitor scan
  - Rollback if needed: `/aos --rollback`
```

## Rollback (`/aos --rollback`)

1. Locate the most recent `.claude/_v1-backup-*` folder. If multiple exist, list them and ask user to pick.
2. Warn: any changes to `.claude/` made after the backup will be lost. List specific files modified after backup mtime if practical.
3. Confirm with user (`yes` required).
4. Execute:
   ```bash
   # Save anything we want to preserve first (e.g., user explicitly asked)
   rm -rf .claude/*  # but keep .claude itself
   cp -r .claude/_v1-backup-YYYYMMDD/. .claude/
   rm .claude/aos-version  # ensure v1 state
   ```
5. Log to a fresh episodic entry (v1-style, since we're back in v1): note the rollback.

## Failure handling

If any step fails:

- Pre-Step 1 (before backup): abort, no state changed.
- Steps 1-3: backup exists; abort and tell user to inspect `.claude/_v1-backup-YYYYMMDD/`. Suggest manual fix or rollback.
- Steps 4-12: partial migration. Tell user the last successful step. Offer rollback OR continue-from-step-N (user choice).

Never leave the workspace in an inconsistent state without telling the user. Inconsistent here means: `.claude/aos-version` written but earlier steps incomplete, OR Tracker moved without MEMORY.md index, OR new skills installed without hook update.
