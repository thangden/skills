---
name: aos
description: >-
  Use this skill when the user wants to set up or upgrade an Agentic OS
  workspace — phrases like "set up workspace for my team", "configure
  Claude for our team", "set up CLAUDE.md + memory + hooks", "onboard a
  new workspace", "bootstrap the AI layer", "initialize an AI operating
  system", "init .claude/", "set up 5 layers", "upgrade aos to v2", or
  any intent to make Claude act as a real team member with persistent
  memory and quality gates. Supports three modes: fresh setup (default),
  /aos --upgrade for migrating a v1 workspace to v2, and /aos --rollback
  for reverting a migration via the backup folder. Works for both Tech
  (engineers, devs) and Non-Tech (BD, MKT, OPS, product) teams.
---

# Skill: aos v2 — Agentic OS Setup

Bootstrap or upgrade a 5-layer Agentic OS workspace: **Kernel** (CLAUDE.md + SOUL.md) → **Memory** (Workspace + User scopes) → **Rules** (paths-scoped progressive disclosure) → **Hooks** (Stop + SessionStart, warn-only) → **Agents + Skills** (Curator, Janitor, team-specific personas).

**Authority:** [CONTEXT.md](CONTEXT.md) (glossary, 17 terms) and [docs/adr/0001-0007](docs/adr/) (architecture decisions). Always read the relevant ADR before deviating from the patterns in this file.

---

## Modes

- **`/aos`** (default) — generate a fresh workspace, OR fill gaps in an existing one (Detection Gate decides)
- **`/aos --upgrade`** — migrate a v1 workspace to v2 per [migrations/v1-to-v2.md](migrations/v1-to-v2.md) ([ADR-0007](docs/adr/0007-migration-v1-to-v2.md))
- **`/aos --rollback`** — restore from `.claude/_v1-backup-*` (only valid after `--upgrade`)

---

## PHASE 0A: Context Scan

**Run before any question. Stop when context is sufficient, max 5 files.**

Read in priority order:

1. `README.md` — project description, team info, tech stack
2. `package.json` / `pyproject.toml` / `Cargo.toml` — language and framework
3. `CLAUDE.md` (if present) — existing rules, personas, constraints
4. Top-level folder listing — workflow hints from folder names
5. `.env.example` or `docker-compose.yml` — environment / services

**Scan limits:** skip files > 50KB; **never read actual `.env` files**.

After scanning, summarize for the user:

```text
Scan summary:
- Team type: [Tech FE / Tech BE / Non-Tech / Unknown]
- Tech stack: [Next.js + TS / Python FastAPI / N/A]
- Primary workflow hint: [from folder names: proposals/, content/, reports/...]
- Existing aos: [v1 detected / v2 detected / nothing found]

Anything to correct before I proceed?
```

**Inference → skipped questions** (apply only after user confirms scan summary):

| Inferred from scan | Phase 1 question to skip |
| --- | --- |
| README clearly describes team & role | [1] Team & Role |
| `package.json` / lockfile with framework | Tech stack portion of [6] |
| Folders like `proposals/`, `content/`, `reports/` exist | [3] Folder Structure |
| `CLAUDE.md` has red lines / safety constraints | [4] and [5] |

---

## PHASE 0B: Detection Gate

After Phase 0A, inspect `.claude/` and `aos-version`:

| State detected | Default mode | Action |
| --- | --- | --- |
| `.claude/` absent | `/aos` fresh | Skip to Phase 1 |
| `.claude/aos-version` = `2.1.0` (current) | `/aos` fill-gaps | Show fill-gaps preview, then Phase 1 only for what's missing |
| `.claude/aos-version` = `2.0.0` (older v2.0) | `/aos` fill-gaps → v2.1 | Add the v2.1 delta — `verify-gate.sh` + `config.env` + `feature-evaluator.md` + `features/`, register verify-gate on Stop — then bump `aos-version` to `2.1.0` |
| `.claude/aos-version` absent, `.claude/memory/system-knowledge.md` present | v1 detected | Suggest `/aos --upgrade`; if user insists on fresh, ask whether to backup existing first |
| `.claude/` present but no aos markers (not a v1 workspace either) | Manual choice | Ask: A) full fresh, overwrite OR B) fill-gaps, keep existing |

For fill-gaps mode, render a dry-run preview:

```text
Dry-run preview — files to be created or skipped:
✓ Create: .claude/skills/curator.md (not found)
- Skip: .claude/agents/bd-senior.md (already exists)
✓ Create: .claude/skills/janitor.md (not found)
✓ Update: CLAUDE.md (add Memory Layer section)

Proceed? (yes / no)
```

**Stop-loss for ambiguous workspaces:** if multiple CLAUDE.md files from different projects are detected (e.g. monorepo with subprojects each having their own), ask the user to confirm which workspace is the target before continuing.

---

## PHASE 0C: Mode Dispatch

Based on user explicit flag and Detection Gate:

- User typed `/aos --upgrade` → go to **PHASE 2-UPGRADE**
- User typed `/aos --rollback` → go to **PHASE 2-ROLLBACK**
- Detection says v1, user wants upgrade → **PHASE 2-UPGRADE**
- Otherwise → **PHASE 1** (interview), then **PHASE 2-FRESH** (or fill-gaps)

---

## PHASE 1: Dynamic Interview

**Rules:**

- Ask **one question at a time**, wait for an answer before the next.
- Do not announce question numbers. Ask naturally.
- If the user's answer covers multiple questions, merge and skip the related ones.
- Skip any question already answered by Phase 0A.

**Stop-loss:** If after 3-4 questions the user gives only vague answers ("I don't know", "anything works"), STOP. Do not generate. Return:

> *"aos needs specific information about your workflow and output structure to set up correctly. Please clarify your intent and run `/aos` again."*

**Six questions:**

**[1] Team & Role**
> "Which team or role are you setting this up for? What is their primary job?"

**[2] Anchor Use Case** *(never skip — most important)*
> "Describe the team's most important workflow: from **what input**, through **what steps**, to **what output**? Example: Meeting notes → research the company → draft proposal → final proposal."

**[3] Folder Structure**
> "Where is that output usually saved? Are there other folders the team works in regularly?"

**[4] Red Lines**
> "Name 2-3 things AI must absolutely never do or commit to in this workspace."

**[5] Safety Constraints**
> "What information must never be shared or committed without explicit approval? (pricing, contracts, client data, internal roadmap...)"

**[6] Tone & Domain Knowledge**
> "What's the team's communication style — professional, casual, data-driven, creative? And what domain knowledge does the agent need (ICP, pricing tiers, objection handling, technical context)?"

---

## PHASE 2-FRESH: Generation for new workspace

Generate files in order Layer 1 → Layer 5. Use Curator's **interview-mode** for memory seed Entries ([ADR-0006](docs/adr/0006-curator-on-self-seed.md)).

### Layer 1 — Kernel

**`CLAUDE.md`** — DYNAMIC, composed from interview answers. Keep under 200 lines. Required sections:

- `# CLAUDE.md — <Workspace name>` title
- `## Mission` — from [1] + [2]
- `## ICP` — who the team serves (from [1])
- `## Golden Rules` — 2-3 rules drawn from [4]
- `## Default Output Format` — markdown headers, bullet caps, file-path style
- `## Tone` — from [6], short sentences, numbers over adjectives
- `## Skill Routing` — list `.claude/skills/curator.md` and `.claude/skills/janitor.md` as memory ecosystem
- `## Agent Routing` — list `.claude/agents/` priority; mention `[team]-senior` and `research-analyst`
- `## Memory Layer` — describe the two Scopes (`team` → Workspace Memory, `personal` → User Memory) per [ADR-0001](docs/adr/0001-memory-scope-routing.md); note Curator default is `team`
- `## Source of Truth` — link CONTEXT.md (if applicable), tracker, MEMORY.md
- `## Operating Constraints` — 1 session = 1 goal, `/compact` discipline, Memory Guard warn-only (per [ADR-0005](docs/adr/0005-hook-architecture.md)). Use `/rewind` before risky/speculative edits. Reuse the superpowers SDLC skills (`tdd`, `verification-before-completion`, `subagent-driven-development`, `systematic-debugging`) rather than reinventing.

**`SOUL.md`** — DYNAMIC. Runtime policies and red lines:

- `## What this AI is allowed to do` — concrete capabilities granted
- `## What this AI must NOT do without explicit instruction` — destructive ops, pushes, etc.
- `## Information that must never appear` — from [5]
- `## Tone Guide` — detailed version of CLAUDE.md tone
- `## Red Lines` — bullet list from [4]

### Layer 2 — Memory + Tracker

Create in this order:

1. **`.claude/aos-version`** (STATIC) — single line `2.1.0`.

2. **`.claude/active-context.md`** (DYNAMIC) — the **Tracker**, not a Memory Entry ([ADR-0002](docs/adr/0002-entry-schema-and-tracker-separation.md)):

   ```markdown
   # Active Context — Sprint Tracker

   Mutable sprint state. Not a Memory Entry — lives outside `.claude/memory/`.

   ## In Progress
   - [ ] Customize agent persona with real domain knowledge

   ## To Do
   - [ ] Run the anchor workflow end-to-end for the first time
   - [ ] Reference domain knowledge and route via Curator into Memory

   ## Done
   - [x] aos v2 5-layer setup complete

   _Last updated: <YYYY-MM-DD>_
   ```

3. **`.claude/memory/`** directory + seed Entries via Curator interview-mode. For each Phase 1 answer, invoke Curator with metadata `source: aos-interview, question-key: <q-key>`:

   | Question | question-key | Resulting Entry |
   | --- | --- | --- |
   | [1] Team & Role | `team-role` | `type: project, scope: team, name: team-role` |
   | [2] Anchor Use Case | `anchor-workflow` | `type: project, scope: team, name: anchor-workflow` |
   | [3] Folder Structure | `folder-structure` | `type: reference, scope: team, name: folder-structure` |
   | [4] Red Lines | `red-lines` | `type: feedback, scope: team, name: red-lines` |
   | [5] Safety Constraints | `safety-constraints` | `type: feedback, scope: team, name: safety-constraints` |
   | [6] Tone & Domain Knowledge | `tone-style` (split into two if needed: `tone-style` + `domain-knowledge`) | `type: feedback, scope: team` and `type: project, scope: team` |

   Curator interview-mode (per ADR-0006) skips confidence questions and uses the `question-key` as filename slug deterministically.

4. **`.claude/memory/MEMORY.md`** — DYNAMIC index. Group seed Entries by `type` (Project / Feedback / Reference / User), one bullet each: `- [name](name.md) — first line of description`.

5. **`_archive/`** — do NOT pre-create. Janitor creates it on first `/clean-memory --apply`.

6. **`.claude/features/`** (Tech only, [ADR-0009](docs/adr/0009-feature-list-primitive.md)) — feature work-units (work-unit STATE, **not** Memory; keeps the 4-type rule intact). Do NOT pre-create features; copy `templates/features/feature-template.md` → `.claude/features/_TEMPLATE.md` as the reference shape. The harness flips a feature to `passing` via the **feature-evaluator** skill, never the implementing agent.

7. **`.claude/DECISIONS.md`** — copy `templates/DECISIONS.md`. Log hard-to-reverse decisions + the *why* (continuity artifact, harness-eng L5); ADR-grade ones go to `docs/adr/`.

### Layer 3 — Rules

Three files in `.claude/rules/`:

**`brand-voice.md`** (STATIC, no `paths`) — copy from `templates/rules/brand-voice.md`. This file loads globally, every turn.

**`<primary>-rules.md`** (DYNAMIC, `paths`-scoped) — named after the primary output folder from [3]. Example for a BD team with `proposals/`:

```yaml
---
description: Rules for proposal creation — only loaded when working with proposals/
paths: ["proposals/**"]
---
```

Content: required structure for proposals, pre-finalization checklist, ICP-specific framing.

**`<secondary>-rules.md`** (DYNAMIC, `paths`-scoped) — named after the secondary folder from [3], if any. Same structure.

### Layer 4 — Hooks

Per [ADR-0005](docs/adr/0005-hook-architecture.md) wire **Stop + SessionStart** (warn-only memory hooks); plus the **verify-gate** ([ADR-0008](docs/adr/0008-verify-gate.md)) for language-agnostic code verification.

**Copy from `templates/hooks/`:**

- Memory hook (variant by team type):
  - **Tech** (git present): `memory-stop.sh` → `.claude/hooks/memory-stop.sh`
  - **Non-Tech** (no git / Non-Tech team): `memory-stop-nontech.sh` → `.claude/hooks/memory-stop.sh`
- Always: `janitor-surface.sh`, `janitor-delta.sh` → `.claude/hooks/`
- **Tech only**: `verify-gate.sh` + `post-tool-format.sh` + `config.env` → `.claude/hooks/`

Make hooks executable: `chmod +x .claude/hooks/*.sh`.

**Generate `.claude/hooks/config.env`** from Phase 0A tech-stack detection + interview [3]/[4]. Fill verify commands for the detected stack — leave a value empty to skip that step; **never invent a command the repo does not have**:

| Detected stack | COMPILE_CMD | LINT_CMD | TEST_CMD |
| --- | --- | --- | --- |
| Node/TS (`package.json` + tsconfig) | `npx tsc --noEmit` | `eslint .` (if configured) | `vitest run` / `npm test` |
| Go (`go.mod`) | `go build ./...` | `go vet ./...` | `go test ./...` |
| Python (`pyproject.toml` / `requirements.txt`) | `mypy .` (if configured) | `ruff check .` (if configured) | `pytest -q` |
| Non-Tech / unknown | *(empty)* | *(empty)* | *(empty)* |

Set `VERIFY_GATE_MODE=block` for Tech repos, `off` for Non-Tech. Fill `PROTECTED_PATHS` / `RBAC_MARKERS` from [4] if the team named protected areas (e.g. auth routes), and `RED_LINE_PATTERNS` from [4] for paths that must never reach main (e.g. `mock/`).

Copy `templates/settings.json` → `.claude/settings.json` (registers Stop → memory-stop + verify-gate, **PostToolUse → post-tool-format** (auto-format the edited file via `FORMAT_CMD`), SessionStart → janitor-surface).

### Layer 5 — Agents + Skills

**Agents** (`.claude/agents/`):

- **`<team>-senior.md`** (DYNAMIC) — name dynamic from team type. Persona built from [1], [2], [6]. Required sections:
  - YAML frontmatter: `name`, `description`, `model: sonnet`, and `tools:` scoped to team type — **Tech**: `Read, Grep, Glob, Edit, Write`; **Non-Tech**: `Read, Grep, Glob` (least-privilege; add `Bash` only if the role truly needs it)
  - `## Persona` — experience level, how they think, communication style
  - `## Domain Knowledge` — from [6]
  - `## Red Lines` — from [4] and [5]

- **`research-analyst.md`** (STATIC) — copy from `templates/agents/research-analyst.md`.

**Skills** (`.claude/skills/`):

- **`curator.md`** (STATIC) — copy from `templates/skills/curator.md`.
- **`janitor.md`** (STATIC) — copy from `templates/skills/janitor.md`.
- **`feature-evaluator.md`** (STATIC, Tech only) — copy from `templates/skills/feature-evaluator.md` ([ADR-0009](docs/adr/0009-feature-list-primitive.md)).
- **`<anchor>.md`** (DYNAMIC) — name derived from [2] anchor workflow. Required sections:
  - `description:` listing trigger phrases the user might say to invoke this workflow
  - `## When to use` — concrete cues
  - `## Required input` — from [2]
  - `## Execution steps` — typically (1) `@research-analyst` to gather, (2) `@<team>-senior` to draft, (3) review and finalize
  - `## Output` — from [2]
  - `## Trigger` — `/<workflow-name>`

### `.gitignore` updates

Append (deduplicated) to existing `.gitignore`:

```text
.claude/.curator-active
.claude/.janitor-applied
.claude/memory/_archive/
.claude/janitor-report-*.md
.claude/_v1-backup-*/
.claude/hooks-audit-*.log
```

`.claude/features/` and `.claude/hooks/config.env` are **committed** (team-shared) — do not ignore them.

If no `.gitignore` exists, create one with these patterns.

---

## PHASE 2-UPGRADE: Migration v1 → v2

Follow the step-by-step playbook in [migrations/v1-to-v2.md](migrations/v1-to-v2.md). Do not deviate without first writing a new ADR.

Key steps (full detail in playbook):

1. Pre-flight: confirm v1 shape and absent `aos-version`
2. Dry-run preview to user; wait for `yes`
3. Backup `.claude/` → `.claude/_v1-backup-YYYYMMDD/`
4. Split `system-knowledge.md` into per-H2 Entries (Curator interview-mode)
5. Move `active-context.md` to `.claude/active-context.md` (Tracker location)
6. Reformat `episodic/*.md` with frontmatter and flatten subfolder
7. Generate `MEMORY.md` index
8. Copy Curator + Janitor + feature-evaluator skills from templates
9. Replace hook scripts (variant detection) + add `verify-gate.sh` + `config.env`; copy `features/_TEMPLATE.md`
10. Replace `settings.json`
11. Update `CLAUDE.md` (additive sections only)
12. Write `.claude/aos-version` = `2.1.0` (templates now include the v2.1 delta: verify-gate + config.env + feature-evaluator + features/)
13. Log to today's episodic Entry

---

## PHASE 2-ROLLBACK: Restore from backup

Follow the rollback section of [migrations/v1-to-v2.md](migrations/v1-to-v2.md).

1. Locate the most recent `.claude/_v1-backup-*` (if multiple, ask user to pick)
2. Warn about loss of post-upgrade changes
3. Require explicit `yes`
4. Restore: `rm -rf .claude/*` then `cp -r .claude/_v1-backup-YYYYMMDD/. .claude/`
5. Remove `.claude/aos-version` to ensure v1 shape
6. Log the rollback

---

## PHASE 3: Documentation

After PHASE 2-FRESH (do not run after upgrade — the user already has docs):

**`AIOS-README.md`** at workspace root — DYNAMIC. Required sections in plain language:

1. **Setup complete** — "Your aos v2 workspace for `<team>` is ready"
2. **5-Layer anatomy** in plain words (no jargon):
   - Kernel = Constitution, always loaded
   - Memory = Knowledge that persists; Tracker = sprint state
   - Rules = Laws loaded automatically at the right time
   - Hooks = Quality gate (warns, blocks only on schema error)
   - Agents = Specialized team members
3. **Quick Start** — invoke the anchor workflow from `demo-prompts.md`
4. **5 Important tips**:
   - CLAUDE.md < 200 lines; restart Claude Code after editing
   - 1 session = 1 goal; `/compact` when long
   - Hooks warn but rarely block; schema validation is the only hard error
   - Curator routes Memory automatically — `@curator` to force; `@janitor` for cleanup
   - Memory has two Scopes: `team` (committed) and `personal` (your machine)

**`demo-prompts.md`** at workspace root — DYNAMIC. Copy-paste ready:

```markdown
# Demo Prompts — <Team> Workspace

## Full Pipeline — <Anchor Workflow Name>

<Prompt 1: invoke @research-analyst with real input from anchor use case>

<Prompt 2: invoke @<team>-senior with the research output>

/<anchor-workflow-name>

## Test Curator (Memory ecosystem)

ghi nhớ: <a concrete fact relevant to this team, e.g. "ICP is mid-market SaaS companies in APAC">

@curator <some preference, e.g. "always use formal Vietnamese in customer-facing docs">

## Test Janitor

/clean-memory

## Update Tracker before closing session

Mark the current task done in `.claude/active-context.md` if you finished it.
```

---

## Closing notification

After PHASE 2 (any mode) and PHASE 3 complete, tell the user:

> "aos v2 setup complete. Open `demo-prompts.md` and run the first command to test the anchor workflow. Memory ecosystem (Curator + Janitor) is wired — try `ghi nhớ <something>` or `remember <something>` to see Curator route automatically."

For `--upgrade` mode, the closing message also lists the backup path and the rollback command.

---

## ADR cross-reference

| ADR | Topic | What this skill enforces |
| --- | --- | --- |
| [0001](docs/adr/0001-memory-scope-routing.md) | Memory scope routing | Generates only `team` and `personal` Scopes in C-narrow; never creates `~/.claude/memory/` |
| [0002](docs/adr/0002-entry-schema-and-tracker-separation.md) | Entry schema + Tracker separation | Anthropic 4-type frontmatter on every Entry; Tracker outside `.claude/memory/` |
| [0003](docs/adr/0003-curator-trigger-and-routing.md) | Curator trigger + routing | Phase 2 uses Curator interview-mode for memory seed |
| [0004](docs/adr/0004-janitor-trigger-and-action.md) | Janitor trigger + action | Janitor respects auto-delta on Stop + manual full scan |
| [0005](docs/adr/0005-hook-architecture.md) | Hook architecture | Stop + SessionStart warn-only; schema validation is the single block path |
| [0006](docs/adr/0006-curator-on-self-seed.md) | Curator-on-self seed | Phase 2 dogfoods Curator (no parallel static template engine) |
| [0007](docs/adr/0007-migration-v1-to-v2.md) | Migration v1 → v2 | `/aos --upgrade` follows the playbook; `/aos --rollback` provided |
| [0008](docs/adr/0008-verify-gate.md) | Verify gate (configurable) | Stop runs a language-agnostic 3-layer code gate; block/warn/off via `config.env` |
| [0009](docs/adr/0009-feature-list-primitive.md) | Feature-list primitive | Work-units in `.claude/features/`; harness flips `passing` via feature-evaluator |

---

## Glossary

For any term in **bold** above (Workspace, Workspace Memory, User Memory, Scope, Entry, Tracker, Curator, Janitor, Archive, etc.), see [CONTEXT.md](CONTEXT.md) for the locked definition. Do not invent synonyms.
