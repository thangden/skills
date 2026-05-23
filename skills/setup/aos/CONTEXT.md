# Agentic OS

The 5-layer architecture and the skill that bootstraps it. The token "aos" is overloaded — disambiguate per context as **aos skill**, **Agentic OS Architecture**, or **Workspace**.

## Language

### Architecture

**Agentic OS Architecture**:
The 5-layer reference design — Kernel (CLAUDE.md + SOUL.md), Memory, Rules, Hooks, Agents+Skills.
_Avoid_: "the OS", "agentic system"

**aos skill**:
The installable skill at `SKILL.md` that interviews the user and generates an Agentic OS Workspace.
_Avoid_: "the aos", "agentic os tool"

**Workspace**:
A single repository containing a `.claude/` directory configured by the aos skill. One Workspace = one repo = one `CLAUDE.md`.
_Avoid_: "project" (collides with Claude project directory), "folder"

**Claude project directory**:
The harness-managed directory at `~/.claude/projects/<repo-hash>/`. Holds session state, todos, and User Memory. Owned by Claude Code, not by aos.
_Avoid_: "project folder", "project memory"

### Memory layer

**Workspace Memory**:
Memory Entries stored at `<repo>/.claude/memory/`. Git-committed. Shared with team. Default destination for new Entries.
_Avoid_: "project memory", "repo memory"

**User Memory**:
Memory Entries stored at `~/.claude/projects/<repo-hash>/memory/` and managed by the Claude Code harness. Auto-loaded each turn via the `MEMORY.md` index. Not git-committed; lives only on the user's machine.
_Avoid_: "Anthropic memory", "local memory", "auto memory"

**User Global Memory** _(C-broad, not in C-narrow)_:
Memory Entries stored at `~/.claude/memory/`. Intended to load in every Workspace the user opens on this machine, but **has no native Anthropic auto-loader** — a custom loader is required. Deferred to C-broad together with the Promoter agent and a future ADR covering the loader mechanism.
_Avoid_: "global memory", "machine memory"

**Scope**:
Required field on every Memory Entry. In C-narrow: `team` → Workspace Memory, `personal` → User Memory. C-broad adds `global` → User Global Memory. Curator default is `team`.
_Avoid_: "visibility", "level", "tier"

**Entry**:
A single Memory unit — one file with YAML frontmatter plus body. The atomic write/scan unit for Curator and Janitor. Every Entry has a `type` (Anthropic 4-type: `user | feedback | project | reference`) and a `scope` (see Scope).
_Avoid_: "record", "note", "item"

**Tracker**:
The sprint state file at `.claude/active-context.md` (sibling of `.claude/memory/`, not inside it). Mutable In Progress / To Do / Done list. **Not a Memory Entry** — Janitor does not scan it, Curator does not write to it. Lives in its own layer. The Stop hook warns when older than 14 days.
_Avoid_: "active context" (file path is fine, but as a concept use **Tracker**), "todo list", "backlog"

**Marker file**:
Small flag file under `.claude/` used to pass state between Curator, Janitor, and hooks across process boundaries. Two are reserved: `.curator-active` (set by Curator on save, cleared by Stop hook after running delta scan) and `.janitor-applied` (set by `/clean-memory --apply` on success, read by SessionStart hook to suppress already-applied reports). Marker files are git-ignored.
_Avoid_: "flag", "sentinel", "lock"

**Migration**:
The transformation from aos v1 on-disk layout to aos v2. Invoked explicitly via `/aos --upgrade`, never auto-triggered. Writes a **Backup** before transforming and is reversible via `/aos --rollback`. Non-idempotent by design — guarded by the `aos-version` marker.
_Avoid_: "upgrade" (use **Migration** for the process; `--upgrade` is the command), "conversion"

**Backup**:
Pre-migration snapshot at `.claude/_v1-backup-YYYYMMDD/` created by `/aos --upgrade` before any file is transformed. Contains the entire `.claude/` at the moment of upgrade. Restored on `/aos --rollback`. Excluded from Janitor scans and git.
_Avoid_: "snapshot", "rollback folder"

**aos-version**:
Single-line file at `.claude/aos-version` containing the active aos version (e.g. `2.0.0`). Absence indicates v1 (or non-aos workspace). Used by Migration to guard against double-execution and by future upgrades to determine the transformation path.
_Avoid_: "version file"

### Memory ecosystem agents

**Curator**:
Skill that classifies user-provided info and writes it as an Entry into the correct Memory with the correct Scope and Type. Triggered implicitly when Claude detects memory-worthy signals and explicitly when the user calls `@curator` or `/curate`. Has two modes — **runtime** (confidence-driven, may ask one question, free-form filenames) and **interview** (used by aos Phase 2 generation; high-trust source, no confidence question, deterministic filename slugs from `question-key`).
_Avoid_: "memory writer", "router"

**Confidence**:
Curator's internal score for a routing decision. At or above the threshold (current calibration: `0.8`) Curator auto-saves and announces; below it Curator asks exactly one question. The threshold is a tunable knob, not an architectural commitment.
_Avoid_: "certainty", "score"

**Janitor**:
Skill that scans active Memory locations and surfaces Conflict / Stale / Bloat / Duplicate. Two triggers — manual full scan via `@janitor` / `/clean-memory`, and auto-delta on Stop when Curator wrote this session (checks Conflict + Duplicate only). Produces a report; never auto-deletes. User executes the batch via `/clean-memory --apply`. Archived Entries move into the **Archive**, not deleted.
_Avoid_: "memory cleaner", "compactor"

**Archive**:
Reserved directory `.claude/memory/_archive/` where Janitor moves Stale or merged-Duplicate Entries on `/clean-memory --apply`. Not loaded by Claude, not scanned by Janitor as live Memory, restorable by `mv` back to its original location.
_Avoid_: "trash", "deleted", "old"

**Promoter** _(C-broad, not in C-narrow)_:
Skill that detects Entries recurring across multiple Workspaces and proposes promotion from `team` Scope to `global` Scope.
_Avoid_: "publisher"

**Archivist** _(C-broad, not in C-narrow)_:
Skill that summarizes old episodic Entries and moves raw content to cold storage.
_Avoid_: "compactor"

## Relationships

- An **Entry** has exactly one **Scope**.
- **Scope** determines which **Memory** location stores the **Entry**:
  - `team` → **Workspace Memory**
  - `personal` → **User Memory**
  - `global` → **User Global Memory** _(C-broad only)_
- The **aos skill** in C-narrow generates the initial **Workspace** including **Workspace Memory** and **User Memory** plus the **Curator** and **Janitor** skills. **User Global Memory** is not created in C-narrow.
- **Promoter** (C-broad) moves an **Entry** from **Workspace Memory** → **User Global Memory** by changing its **Scope** from `team` to `global`.
- **Janitor** scans the two **Memory** locations active in C-narrow (three in C-broad); **Curator** writes to exactly one per call.
- The **Tracker** is not part of the **Memory** layer — neither **Curator** nor **Janitor** touches it. The Memory Guard hook checks it on a separate channel.

## Example dialogue

> **User:** "Remember: our team operates in three regions."
> **Curator:** "Long-lived fact, no personal context — Scope `team`. Writing Entry to Workspace Memory at `.claude/memory/team-regions.md`."
> **User:** "When does it become global?"
> **Curator:** "Not in C-narrow. Scope `global` and User Global Memory ship with C-broad once the loader ADR and the Promoter-sanitization ADR are written and accepted."

## Flagged ambiguities

- "aos" was used to mean the skill, the architecture, and the installed Workspace — resolved by disambiguating into **aos skill**, **Agentic OS Architecture**, and **Workspace**.
- "project" was used to mean both a repo and a Claude project directory — resolved as **Workspace** for the repo and **Claude project directory** for the harness-managed folder.
- "memory" with no qualifier was ambiguous between Workspace / User / User Global — Entries must always be referenced by Scope or by full location name.
