---
name: aos
description: >-
  Use this skill whenever the user wants to set up an AI workspace for their
  team — including phrases like: set up workspace for my team, configure Claude
  for our team, set up CLAUDE.md + agents + memory + hooks, onboard a new
  workspace, bootstrap the AI layer, initialize an AI operating system, init
  .claude/ from scratch, set up 5 layers for the team, or any intent to make
  Claude act as a real team member. Creates all 5 layers (CLAUDE.md,
  .claude/memory/, .claude/rules/, .claude/hooks/, .claude/agents/) for any
  team type — Sales, Marketing, Operations, Engineering, Product — via a smart
  interview that scans workspace context first.
---

# Skill: AOS — Agentic OS Setup

This skill bootstraps a complete 5-Layer Agentic OS (Kernel → Memory → Rules → Hooks → Agents/Skills) for any team or role. The output is a ready-to-use workspace with `demo-prompts.md` to test immediately after setup.

---

## PHASE 0A: CONTEXT SCAN

**Run before everything — ask nothing until the scan is complete.**

Read the workspace in priority order (stop when context is sufficient, max 5 files):

1. `README.md` — project description, team info, tech stack
2. `package.json` or `pyproject.toml` / `pom.xml` / `Cargo.toml` — language & framework
3. `CLAUDE.md` (if present) — existing rules, personas, constraints
4. Top-level folder structure (`ls -la`) — workflow hints from folder names
5. `.env.example` or `docker-compose.yml` — environment / service hints

**Scan limits:** max 5 files, skip files > 50KB, **never read actual `.env` files**.

After scanning, show a summary for the user to confirm:

```text
I've scanned the workspace and inferred:
- Team type: [Tech FE / Tech BE / Non-tech / Unknown]
- Tech stack: [Next.js 15 + TypeScript / Python FastAPI / N/A]
- Primary workflow hint: [from folder names: proposals/, content/, reports/...]
- Existing AOS config: [CLAUDE.md present / Nothing found]

I'll skip questions about information that's already clear.
Anything to correct before I proceed?
```

**Inference → skipped questions mapping:**

| Inferred from scan | Skip question |
| --- | --- |
| README clearly describes team/role | [1] Team & Role |
| `package.json` / lockfile with framework | Tech stack portion of [6] |
| Folders like `proposals/`, `content/`, `reports/` exist | [3] Folder Structure |
| `CLAUDE.md` has red lines / safety constraints | [4] and [5] |

If user confirms correct → skip corresponding questions in Phase 1.
If user corrects → note the correction, ask that specific question.
If nothing can be inferred (empty repo with no README) → skip scan, go straight to Phase 1.

---

## PHASE 0B: DETECTION GATE

**After scanning, inspect the workspace:**

1. Check whether `.claude/` exists
2. If it **does** → list what's already there:

```text
I see this workspace already has:
- .claude/agents/: [list of files]
- .claude/skills/: [list of files]
- CLAUDE.md: [present / not found]

What would you like to do?
(A) Full fresh setup — overwrite existing files
(B) Fill in the gaps only — keep existing files as-is
```

1. If user picks **(B)** → show a **Dry-run Preview** before creating any file:

```text
Dry-run Preview — files to be created or skipped:
✅ Create: CLAUDE.md (not found)
✅ Create: .claude/memory/ (not found)
⏭  Skip: .claude/agents/bd-senior.md (already exists — keeping as-is)
✅ Create: .claude/skills/[anchor-workflow].md

Confirm? (yes / no)
```

1. If user picks **(A)** or `.claude/` doesn't exist → continue to Phase 1 normally.

**STOP-LOSS for ambiguous workspaces:** If multiple CLAUDE.md files from different projects are detected → ask the user to confirm this is the correct workspace before continuing.

---

## PHASE 1: DYNAMIC INTERVIEW

**Rules:**

- Ask **one question at a time**, wait for an answer before asking the next
- Do not number questions like "Question 1/6" — ask naturally, like a colleague
- If the user's answer covers multiple questions → merge and skip the related ones
- **Skip any question already answered by Phase 0A** — never ask twice

**STOP-LOSS:** If after 3–4 questions the user continues to give vague answers ("I don't know", "up to you", "anything works") → STOP immediately. Do not generate files. Return: *"AOS needs specific information about your workflow and output structure to set up correctly. Please clarify your intent and run `/aos` again."*

**6 questions to collect (combinable, skippable if already inferred):**

**[1] Team & Role**
> "Which team or role are you setting this up for? What is their primary job?"

**[2] Anchor Use Case** *(most important — never skip)*
> "Describe the team's most important workflow: from **what input** → through **what steps** → to **what output**?
> Example: Meeting notes → Research the company → Draft proposal → Final proposal"

**[3] Folder Structure**
> "Where is that output usually saved? Are there other folders the team works in regularly?"
> *(Used to name path-based rules. Examples: `proposals/`, `outreach/`, `content/`, `campaigns/`)*

**[4] Red Lines**
> "Name 2–3 things AI must absolutely never do or commit to in this workspace."

**[5] Safety Constraints**
> "What information must never be shared or committed without explicit approval?"
> *(Examples: pricing matrix, contract terms, client data, internal roadmap)*

**[6] Tone & Domain Knowledge**
> "What's the team's communication style: professional, casual, data-driven, creative...?
> And what domain-specific knowledge does the agent need?" *(Ideal Customer Profile (ICP), pricing tiers, objection handling, technical details...)*

---

## PHASE 2: GENERATION

Once enough information is collected — **ask nothing more** — create files in order from Layer 1 to Layer 5.

---

### Layer 1 — Kernel

**`CLAUDE.md`** — Constitution, must stay under 200 lines:

- Team description + primary mission
- Ideal Customer Profile (ICP) / who the team serves
- 2–3 golden rules (from red lines in Phase 1)
- Default output format (markdown with clear headers)
- Standard tone
- Skill Routing: explicit link to `.claude/skills/` to prioritize project-level skills over global ones
- Agent Routing: explicit link to `.claude/agents/` to prioritize project-level personas over global ones

**`SOUL.md`** — Runtime policies:

- What the agent is allowed to do
- Safety constraints: information not to be shared or committed (from Phase 1 [5])
- Detailed tone guide
- Red lines as a bullet list

---

### Layer 2 — Memory

Create folder **`.claude/memory/`** with 3 core components:

**`.claude/memory/system-knowledge.md`** — Long-term architectures & decisions index:

- Seed with 3–5 entries from Phase 1 information
- Entry format: `- [Important decision/fact ~150 chars] → [link to detail file if any]`

**`.claude/memory/active-context.md`** — Active state & sprint tracking:

```markdown
# Active Context & Trajectory
Primary task tracker / backlog (Jira, Linear, Notion, etc.). Edit items in this list:

## In Progress
- [ ] Customize agent persona with real team domain knowledge

## To Do
- [ ] Test anchor use case end-to-end for the first time
- [ ] Reference real domain knowledge and record it in system-knowledge.md

## Done
- [x] AI OS 5-layer setup complete
```

**`.claude/memory/episodic/`** — Create empty folder + today's file `YYYY-MM-DD.md`:

- Record a short log: team setup, chosen anchor use case, key architecture decisions

---

### Layer 3 — Rules

Create **3 files** in `.claude/rules/`, names are dynamic based on input:

**File 1: `brand-voice.md`** — No `paths` (loaded globally at all times):

```yaml
---
description: [Team] brand voice and communication standards — loaded globally
---
```

Content: tone guide, words to avoid, team writing standards.

**File 2: `[primary-folder]-rules.md`** — Name = primary output folder (e.g., `proposal-rules.md`):

```yaml
---
description: Rules for [primary task] — only loaded when working with [primary-folder]/
paths: ["[primary-folder]/**"]
---
```

Content: required structure for primary output, pre-finalization checklist.

**File 3: `[secondary-folder]-rules.md`** — Name = secondary folder (e.g., `outreach-rules.md`):

```yaml
---
description: Rules for [secondary task] — only loaded when working with [secondary-folder]/
paths: ["[secondary-folder]/**"]
---
```

Content: rules specific to the secondary task.

---

### Layer 4 — Hooks

**`.claude/settings.json`**:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/quality-gate.sh"
          }
        ]
      }
    ]
  }
}
```

**`.claude/hooks/quality-gate.sh`** — Quality Gate + Memory Guard.

Two variants depending on team type inferred in Phase 0A:

**Variant A — Non-tech teams (BD, MKT, OPS):** file-based checks, no git commands:

```bash
#!/bin/bash
# Stop hook — Quality Gate & Memory Guard

OUTPUT_DIR="[primary-folder-from-phase1]"
MIN_LINES=5
ERRORS=0

# -- 1. Output Check --
if [ ! -d "$OUTPUT_DIR" ]; then
  echo "Warning: No output found in $OUTPUT_DIR — if the task required creating files, please check." >&2
else
  LATEST=$(find "$OUTPUT_DIR" -maxdepth 2 -name "*.md" -newer "$OUTPUT_DIR" 2>/dev/null | head -1)
  if [ -n "$LATEST" ]; then
    LINE_COUNT=$(wc -l < "$LATEST")
    if [ "$LINE_COUNT" -lt "$MIN_LINES" ]; then
      echo "BLOCKED: $LATEST has only $LINE_COUNT lines — looks incomplete." >&2
      ERRORS=1
    else
      echo "Output check passed — $LATEST ($LINE_COUNT lines)" >&2
    fi
  fi
fi

# -- 2. Memory Guard --
MEMORY_DIR=".claude/memory"
if [ -d "$MEMORY_DIR" ]; then
  RECENT_MEM=$(find "$MEMORY_DIR" -type f -mmin -30 2>/dev/null)
  if [ -n "$RECENT_MEM" ]; then
    echo "Memory updated" >&2
  else
    echo "BLOCKED: Memory not updated!" >&2
    echo "Rule: Mark [x] in active-context.md or write a log to episodic/!" >&2
    ERRORS=1
  fi
fi

[ "$ERRORS" -eq 1 ] && { echo "Quality gate FAILED." >&2; exit 2; }
echo "All checks PASSED" >&2
exit 0
```

**Variant B — Tech teams (FE, BE, Full-stack):** adds git-aware checks, uses `find` instead of glob for portability:

```bash
#!/bin/bash
# Stop hook — Quality Gate & Memory Guard (Tech variant)

ERRORS=0

# -- 1. Secret Detection (git-aware) --
if git rev-parse --git-dir > /dev/null 2>&1; then
  if git diff --cached 2>/dev/null | grep '^\+' | grep -v '^\+\+\+' \
     | grep -iE "(password|secret|api_key|token)\s*=\s*['\"][^'\"]{8,}" > /dev/null 2>&1; then
    echo "BLOCKED: Hardcoded secret detected in staged changes!" >&2; ERRORS=1
  else
    echo "Secret scan passed" >&2
  fi
  # .env guard
  if git diff --cached --name-only 2>/dev/null | grep -E '^\.env$' > /dev/null 2>&1; then
    echo "BLOCKED: .env staged — do not commit credentials!" >&2; ERRORS=1
  fi
fi

# -- 2. Output Check (use find, not glob /**/) --
SRC_DIR="[primary-source-dir-from-phase1]"   # e.g. apps/web/src/components
if [ -d "$SRC_DIR" ]; then
  LATEST=$(find "$SRC_DIR" -type f \( -name "*.ts" -o -name "*.tsx" \) -newer "$SRC_DIR" 2>/dev/null | head -1)
  if [ -n "$LATEST" ]; then
    LINE_COUNT=$(wc -l < "$LATEST")
    [ "$LINE_COUNT" -lt 5 ] && { echo "BLOCKED: $LATEST too short ($LINE_COUNT lines)" >&2; ERRORS=1; } \
                             || echo "Code check passed — $LATEST" >&2
  fi
fi

# -- 3. Memory Guard --
MEMORY_DIR=".claude/memory"
if [ -d "$MEMORY_DIR" ]; then
  RECENT_MEM=$(find "$MEMORY_DIR" -type f -mmin -30 2>/dev/null)
  [ -n "$RECENT_MEM" ] && echo "Memory updated" >&2 \
    || { echo "BLOCKED: Memory not updated — check active-context.md!" >&2; ERRORS=1; }
fi

[ "$ERRORS" -eq 1 ] && { echo "Quality gate FAILED." >&2; exit 2; }
echo "All checks PASSED" >&2
exit 0
```

> **Generation notes:**
>
> - Use Variant A for non-tech (BD, MKT, OPS), Variant B for tech (FE, BE, Full-stack)
> - Replace `[primary-folder]` / `[primary-source-dir]` with real folder names from [3] / Phase 0A scan
> - Never use bash glob `**/*.ext` — use `find` for portability on macOS (bash 3.x)
> - Scripts use `>&2` so Claude receives feedback from the hook

---

### Layer 5 — Agents + Skill

**Agent 1: `.claude/agents/[team]-senior.md`** — Name is dynamic based on team:

```yaml
---
name: [team]-senior
description: [Persona description — experience, domain knowledge, communication style, from Phase 1 [6]]
model: sonnet
tools: []
---

# [Team] Senior Agent

## Persona
[Detail: background, experience, how they think]

## Domain Knowledge
[Team-specific knowledge from Phase 1: ICP, pricing, objection handling, technical knowledge...]

## Red Lines
[What this agent must never do — from Phase 1 [4] and [5]]
```

**Agent 2: `.claude/agents/research-analyst.md`** — Fixed, never changes:

```yaml
---
name: research-analyst
description: Read-only research specialist. Thorough, factual, always flags uncertainty. Never writes or edits files.
model: haiku
tools: [Read, Grep, Glob]
---

# Research Analyst Agent

## Persona
Systematic researcher. Prioritizes verified sources; explicitly flags uncertainty rather than filling gaps with inference.
When uncertain → writes "Not yet verified" rather than guessing.

## Approach
- Read multiple sources before drawing conclusions
- Return structured summaries with confidence levels
- Flag all information that needs further verification
```

**Skill: `.claude/skills/[anchor-workflow-name].md`** — Name = workflow name from anchor use case:

```yaml
---
description: [Workflow description — what input → what output]
---
```

Content:

- **When to use:** trigger conditions
- **Required input:** input type from anchor use case (e.g. meeting notes, raw report, brief)
- **Execution steps:**
  1. `@research-analyst` — research/analyze input
  2. `@[team]-senior` — process and draft output
  3. Review and finalize
- **Output:** output type from anchor use case
- **Trigger:** `/[anchor-workflow-name]`

---

## PHASE 3: DOCUMENTATION

**`AIOS-README.md`** at root:

Required layout:

1. **Setup complete** — "Your AI OS for [X] team is ready"
2. **5-Layer Anatomy** in plain language (no code jargon):
   - Kernel = Constitution, always loaded
   - Memory = Long-term memory, never forgotten (`system-knowledge`, `active-context`)
   - Rules = Laws that load automatically at the right time, saving context
   - Hooks = Iron discipline (Memory Guard), AI cannot skip it
   - Agents = Specialized team members, each with one job
3. **Quick Start** — run the anchor use case immediately using `demo-prompts.md`
4. **5 Important Tips:**
   - CLAUDE.md < 200 lines, restart Claude Code after editing it
   - 1 session = 1 goal, use `/compact` when sessions grow long
   - Hooks with exit code 2 block task completion
   - Keep Memory always updated by the agent at the end of each session
   - Use `@agent-name` to invoke directly, faster than letting the orchestrator choose

**`demo-prompts.md`** at root — copy-paste ready, real content from anchor use case:

```markdown
# Demo Prompts — [Team] Workspace

## Full Pipeline — [Anchor Use Case Name]
[Prompt 1 — invoke research-analyst with real input from anchor use case]

[Prompt 2 — invoke [team]-senior with output from previous step]

/[skill-name]

## Test individual agents
@research-analyst [sample research task relevant to the team]

@[team]-senior [sample execution task relevant to the team]

## Update memory after task
Important: Before closing this session, check off the completed task in `.claude/memory/active-context.md` and write a short log in `.claude/memory/episodic/[today].md` to satisfy the Memory Guard hook.
```

---

End of Phase 3: notify the user —
> "AI OS setup complete. Open `demo-prompts.md` and run the first command to test."
