# 0006 — aos Phase 2 Generation: Curator-on-Self Seed

**Context.** aos v1 Phase 2 wrote `.claude/memory/system-knowledge.md` and `.claude/memory/active-context.md` directly from a hard-coded template, never invoking Curator. v2 introduces Curator as the canonical router (ADR-0003) and shifts to one-Entry-per-file with 4-type schema (ADR-0002). We had to decide whether Phase 2 keeps its own answer-to-file mapping or delegates to Curator the way runtime saves do.

**Decision.** Phase 2 uses **Curator-on-self**: every interview answer is fed to Curator with metadata identifying its provenance (`source: aos-interview`, `question-key: q1-team-role`, etc.). Curator runs in **interview-mode**: high-trust source bypasses the confidence question, filename slug is derived deterministically from `question-key`, default `scope: team`. Runtime mode (confidence-driven, may ask one question) is unchanged. Curator owns all routing decisions in both setup and runtime — there is one routing code path.

**Why.** Optimal agentic architecture has one specialized agent per concern, and other components delegate rather than duplicate. A static seed mapping in aos Phase 2 would mean two routing implementations — one in aos generation code, one in Curator — drifting independently. Improvements to Curator (new types, smarter type inference, better deduplication) would not propagate to setup; setup bugs would not surface in Curator tests; the system would not dogfood its own primitive. Curator-on-self collapses these into one path. The predictability concern (filename non-determinism, setup failure on Curator bug) is addressed by interview-mode: deterministic naming from question keys, bypassed confidence gating for high-trust source. Bugs in Curator surfacing at setup are a feature, not a flaw — they catch issues before user-facing runtime.

**Considered options.**

- α Static template seed — rejected: duplicates routing logic, no dogfood, no propagation of Curator improvements.
- β Curator-on-self with interview-mode — chosen.
- γ Hybrid (static for unambiguous answers, Curator for ambiguous) — rejected: introduces a meta-rule about which path to take, technical debt at the architecture layer.

**Consequences.**

- Curator gains an explicit mode parameter: `interview` vs `runtime`. The mode controls confidence gating and naming policy. Other behavior (Entry shape, Archive contract, marker file write) is identical.
- Phase 2 generation code loops over interview answers and calls Curator; no separate routing recipe lives in aos.
- Curator must be solid before C-narrow ships — setup is its first test. Curator is added to the C-narrow test plan as a P0 dependency.
- Anchor-workflow answer (Q6 interview) generates an Entry; the workflow skill itself is generated separately under `.claude/skills/[anchor].md` (existing v1 behavior).

## Phase 2 File Inventory (consequence summary)

When `/aos` runs on a fresh repo with no existing `.claude/`, the following files are created:

```
<repo>/
├── CLAUDE.md                         updated template — mentions Curator/Janitor, 2 Scopes
├── SOUL.md                           v1 carry-over
├── .gitignore                        adds .claude/.curator-active, .janitor-applied, _archive/, janitor-report-*.md
├── AIOS-README.md                    Phase 3 doc — v2 patterns
├── demo-prompts.md                   Phase 3 — added Curator/Janitor test prompts
└── .claude/
    ├── aos-version                   "2.0.0" — marker for future upgrades
    ├── active-context.md             Tracker (was in memory/ in v1)
    ├── memory/
    │   ├── MEMORY.md                 index file listing all Entries
    │   └── [Entries seeded via Curator interview-mode from 6 interview answers]
    │       — typically: team-role.md, icp.md, red-lines.md, tone-style.md,
    │         anchor-workflow.md, safety-constraints.md
    │       — _archive/ not pre-created; Janitor makes it lazily on first --apply
    ├── skills/
    │   ├── curator.md                memory ecosystem
    │   ├── janitor.md                memory ecosystem
    │   └── [anchor].md               v1 carry-over, dynamic name
    ├── agents/
    │   ├── [team]-senior.md          v1 carry-over, dynamic name
    │   └── research-analyst.md       v1 carry-over, fixed
    ├── rules/
    │   ├── brand-voice.md            v1 carry-over, no paths
    │   ├── [primary]-rules.md        v1 carry-over, paths-scoped
    │   └── [secondary]-rules.md      v1 carry-over, paths-scoped
    ├── hooks/
    │   ├── memory-stop.sh            Stop hook — warn-only (ADR-0005)
    │   ├── janitor-surface.sh        SessionStart hook
    │   └── janitor-delta.sh          helper called by memory-stop.sh
    └── settings.json                 registers Stop + SessionStart hooks
```

User Memory at `~/.claude/projects/<repo-hash>/memory/` is not created by aos — the Anthropic harness creates it when Curator first writes a `scope: personal` Entry. aos must not assume it exists.

Tech vs Non-Tech variant: only `memory-stop.sh` differs (Tech adds secret scan + `.env` guard); all other files are identical.
