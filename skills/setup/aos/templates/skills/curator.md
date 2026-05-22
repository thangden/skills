---
name: curator
description: >-
  Routes user-provided information into the correct Memory location with the
  correct Scope and Type. Triggered implicitly when the user signals a save
  ("ghi nhớ", "remember", "from now on", "đừng X anymore", or shares a durable
  fact, preference, workflow rule, or external pointer) and explicitly via
  @curator or /curate. Hybrid confidence-driven routing — auto-saves at high
  confidence and asks one targeted question at low confidence. See
  aos/docs/adr/0003-curator-trigger-and-routing.md.
---

# Curator — Memory Routing Skill

Routes information into Workspace Memory (`scope: team`) or User Memory (`scope: personal`) using Anthropic's 4-type Entry schema (`user | feedback | project | reference`).

Authority: [aos/docs/adr/0003-curator-trigger-and-routing.md](../../aos/docs/adr/0003-curator-trigger-and-routing.md) and [aos/CONTEXT.md](../../aos/CONTEXT.md).

---

## When to trigger

**Implicit** (Claude invokes Curator without user typing the command):

- User cue phrases — `ghi nhớ`, `remember`, `from now on`, `đừng X`, `don't X anymore`, `apply X going forward`
- Content shape — user states a durable fact, a preference, a workflow rule, an external system pointer, a collaboration guideline

**Explicit**:

- User types `@curator <info>` or `/curate <info>`

If neither implicit nor explicit signal is present, do not invoke Curator. Casual conversation is not memory material.

---

## Two modes

### `runtime` (default — for ad-hoc user input)

- Classify Scope and Type from context, assign a confidence score
- If `confidence >= 0.8`: auto-save and announce
- If `confidence < 0.8`: ask exactly one targeted question (the dimension least sure about — usually Scope or Type, never both) and save on the answer

### `interview` (for aos Phase 2 generation; high-trust source)

- Input metadata includes `source: aos-interview, question-key: <key>`
- Bypass the confidence question; treat as high-trust
- Derive filename slug deterministically from `question-key`
- Default Scope is `team` unless metadata specifies otherwise

---

## Decision matrix (runtime mode)

| Signal in user input | Suggested Type | Suggested Scope |
|---|---|---|
| About the user's role / preferences / habits | `user` | `personal` |
| Guidance on how to collaborate, what to avoid, what to keep doing | `feedback` | `team` (workspace-wide) or `personal` (user-specific) |
| State/decisions about ongoing work, durable facts about the project context | `project` | `team` |
| Pointer to an external system (Linear, Grafana, Notion, doc URL) | `reference` | `team` |

When the entry covers multiple types, pick the dominant one and add cross-references in the body.

---

## Save procedure

1. **Compose the Entry**:

   ```yaml
   ---
   name: <slug>
   description: <one line, used by Claude to decide relevance>
   type: user | feedback | project | reference
   scope: team | personal
   ---
   
   <body — for feedback/project, structure as: rule/fact, then **Why:** and **How to apply:**>
   ```

2. **Filename**:

   - Runtime mode: derive slug from a concise summary of the content (lowercased, hyphenated, ≤4 words)
   - Interview mode: slug = `question-key` from metadata

3. **Path**:

   - `scope: team` → `.claude/memory/<slug>.md` (git-committed)
   - `scope: personal` → `~/.claude/projects/<repo-hash>/memory/<slug>.md` (harness-managed, machine-local)

4. **Write the marker** (always, on every save): `touch .claude/.curator-active` — the Stop hook reads this to know whether to trigger Janitor delta scan ([ADR-0005](../../aos/docs/adr/0005-hook-architecture.md)).

5. **Update the index** if Scope is `team`: append a one-line bullet to `.claude/memory/MEMORY.md` under the appropriate type subheading.

6. **Announce**:

   ```
   Saved: <path>
     scope: <team|personal>
     type: <user|feedback|project|reference>
     confidence: <0.0-1.0>  (runtime mode only)
   Reply `no` or `override scope=<x>` / `override type=<x>` to relocate.
   ```

7. **Log to today's episodic Entry** at `.claude/memory/episodic-YYYY-MM-DD.md`:

   - Append a line: `<timestamp> — Curator saved <path> (scope=<x>, type=<x>, confidence=<x>)`
   - If today's episodic Entry does not exist, create it as `type: project, scope: team`

---

## Reversal

User can reply with any of:

- `no` — most recent save is rolled back (file deleted; marker cleared if appropriate)
- `override scope=<value>` — move Entry to the other Scope location
- `override type=<value>` — rewrite frontmatter `type`
- `rename <new-slug>` — rename the file

Log reversals to today's episodic Entry.

---

## What NOT to save

Mirror the platform guidance (Anthropic system memory rules):

- Code patterns, conventions, architecture, file paths — derivable from current project state
- Git history, recent changes — `git log` is authoritative
- Debugging recipes — commit messages and code carry the context
- Anything already documented in CLAUDE.md, SOUL.md, or ADRs (cite the path instead)
- **Ephemeral task state** — sprint progress lives in `.claude/active-context.md` (the Tracker, [ADR-0002](../../aos/docs/adr/0002-entry-schema-and-tracker-separation.md)), not in Memory

If asked to save one of these, suggest the right home and decline the Memory write.

---

## Conflict handling at write time

Before writing, check whether an Entry with the same `name` slug or a strong semantic match already exists in the target Scope:

- **Exact slug collision**: ask user — overwrite, append, or rename
- **Semantic match suspected** (similar `name`, overlapping `description`): write the new Entry, but the Stop hook's Janitor delta will flag for review next session

Do not auto-merge at write time. Curator writes; Janitor reconciles.
