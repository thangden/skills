---
name: janitor
description: >-
  Scans Memory locations and surfaces Conflict / Stale / Bloat / Duplicate
  Entries. Two triggers — manual full scan via @janitor or /clean-memory, and
  auto-delta on Stop hook when Curator was active this session (Conflict and
  Duplicate only). Produces a report file; never auto-deletes. User executes
  the batch via /clean-memory --apply. Archived Entries move into
  .claude/memory/_archive/, not deleted.
---

# Janitor — Memory Scan and Cleanup Skill

Scans active Memory locations (Workspace Memory, and User Memory if `scope: personal` Entries exist) for four problem classes, produces a report, and executes user-approved cleanup on `--apply`.

---

## When to trigger

**Manual full scan**:

- User types `@janitor` or `/clean-memory`
- Full scan of all active Memory locations and all four detection categories

**Auto-delta**:

- Stop hook fires AND `.claude/.curator-active` marker is present
- Lightweight scan limited to (a) Entries written this session and (b) their neighbors by `name` prefix or `type` match
- Only Conflict and Duplicate categories — Stale and Bloat require time-window data that delta doesn't have

---

## Detection categories

### Conflict

Two or more Entries assert contradictory information on the same topic.

- Heuristic: shared `name` prefix or strong `description` overlap, plus body content that disagrees
- Example: an Entry saying "ICP pricing = $5/unit" and another saying "ICP pricing = $4/unit" — same topic, contradictory body.

### Stale

Entry has not been touched in long enough that its truthfulness is suspect, or it references state that no longer applies.

- `type: project` Entries older than 180 days with no inbound references — candidate
- Rule files (`.claude/rules/*.md`) with `paths:` pointing to non-existent folders — candidate
- Tracker entries marked `In Progress` for over 45 days — candidate (but Tracker is not a Memory Entry; this is a separate scan)

### Bloat

A single Entry has grown past a size where readability and load efficiency degrade.

- File `> 300` lines
- Single section `> 80` lines
- Episodic Entry `> 200` lines for a single day

### Duplicate

Two or more Entries carry near-identical content.

- Exact body match → exact duplicate
- High Jaccard similarity on key phrases → suspected duplicate
- Low-confidence Curator auto-saves are first suspects (read confidence values logged in episodic Entries)

---

## Scan procedure (manual full scan)

1. **Enumerate Entries**:
   - Workspace Memory: `.claude/memory/*.md` (excluding `MEMORY.md`, `_archive/`, `episodic-*.md` indexed separately)
   - User Memory: `~/.claude/projects/<repo-hash>/memory/*.md` (if path exists)
   - Episodic: `.claude/memory/episodic-*.md` for the Stale / Bloat scan

2. **Per-Entry validation**:
   - Frontmatter present and valid (`name`, `description`, `type`, `scope`)
   - File size within Bloat thresholds
   - No broken cross-references

3. **Pairwise checks** (over Entries grouped by topic):
   - Conflict detection across pairs sharing `name` prefix or strong `description` overlap
   - Duplicate detection via body similarity

4. **Tracker check** (separate channel, not a Memory Entry):
   - `.claude/active-context.md` older than 14 days → warn in report under "Tracker freshness" section

5. **Write the report** to `.claude/janitor-report-YYYY-MM-DD.md`:

   ```markdown
   # Janitor Report — YYYY-MM-DD

   Trigger: <manual | auto-delta>
   Scanned: <count> Entries across <locations>
   Health score: <score>/100

   ## Conflict (<count>)
   <list with paths, summary, suggested resolution>

   ## Stale (<count>)
   <list>

   ## Bloat (<count>)
   <list>

   ## Duplicate (<count>)
   <list>

   ## Tracker freshness
   <warning if applicable>

   ## Suggested apply order
   1. Resolve Conflicts (user must mark which side wins per item)
   2. Merge Duplicates (auto-pick the one with higher confidence; user can --skip)
   3. Archive Stale
   4. Split Bloat (manual; Janitor cannot auto-split)
   ```

6. **Do not modify Memory.** The report is read-only output. Wait for `/clean-memory --apply`.

---

## Auto-delta procedure (called by Stop hook)

1. Read `.claude/.curator-active` to confirm Curator was active
2. Read the most recent episodic Entry to identify Entries written this session
3. For each Entry written, find neighbors by `name` prefix or `type` match (max 5 neighbors per Entry)
4. Run Conflict and Duplicate checks only over this subset
5. Append findings to today's `janitor-report-YYYY-MM-DD.md` (create if absent)
6. The Stop hook outputs a one-line summary to stderr; this skill writes the file

---

## Apply procedure (`/clean-memory --apply`)

Reads the most recent `janitor-report-*.md` and executes user-approved actions:

1. **Resolution markers**: before `--apply`, user edits the report and adds `RESOLUTION:` lines under each item:

   ```
   ## Conflict 1
   - .claude/memory/icp-pricing.md vs .claude/memory/icp-pricing-updated.md
   RESOLUTION: keep icp-pricing-updated, archive icp-pricing
   ```

2. **Per-category action**:
   - Conflict: archive the losing side; if the user did not write a RESOLUTION, skip this item and log
   - Duplicate: pick the higher-confidence version, archive the rest
   - Stale: archive
   - Bloat: skip (Janitor does not auto-split; surface as TODO in user's Tracker)

3. **Archive operation**: `mv <path> .claude/memory/_archive/<original-filename>`. Never delete.

4. **State marker**: on success, `touch .claude/.janitor-applied` (timestamp via file mtime). The SessionStart hook checks this to suppress already-applied reports.

5. **Update MEMORY.md index**: remove archived Entry lines.

6. **Log to today's episodic Entry**: list each action taken.

---

## Skip flag

`/clean-memory --apply --skip <item-id>` excludes specific items from the batch. Repeat `--skip` for multiple items. Skipped items remain in the report and are reconsidered on next `--apply`.

---

## Restore

Archive is restorable. `mv .claude/memory/_archive/<filename> .claude/memory/<filename>` brings an Entry back to live. Add a line back to `MEMORY.md` index. Log to episodic.

---

## What Janitor does NOT do

- Auto-delete files (everything goes to Archive)
- Auto-resolve Conflicts (user marks resolution; Janitor only suggests)
- Touch the Tracker (`.claude/active-context.md` is not a Memory Entry — separate freshness warn only)
- Modify files outside `.claude/memory/` and `~/.claude/projects/<repo-hash>/memory/`
- Run on its own schedule (no cron — C-broad concern, deferred)
