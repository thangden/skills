# 0006 — Phase 2 seeds memory by running Curator on its own interview answers

aos v1 Phase 2 wrote `.claude/memory/system-knowledge.md` and `.claude/memory/active-context.md` directly from a hard-coded template, never invoking Curator. v2 introduces Curator as the canonical router (ADR-0003) and shifts to one-Entry-per-file with the 4-type schema (ADR-0002). The question for Phase 2 was whether to keep its own answer-to-file mapping or to feed those answers through Curator the same way runtime saves do.

Phase 2 now runs Curator on itself. Every interview answer is fed to Curator with provenance metadata — `source: aos-interview`, `question-key: q1-team-role`, etc. Curator runs in **interview-mode**: high-trust source bypasses the confidence question, the filename slug is derived deterministically from `question-key`, and the default `scope` is `team`. Runtime mode is unchanged: still confidence-driven, may still ask one question. Curator owns all routing decisions in both setup and runtime — one routing code path.

A static seed mapping in aos Phase 2 would mean two routing implementations, one in aos generation code and one in Curator, drifting independently. Improvements to Curator (better type inference, smarter deduplication) wouldn't propagate to setup. Setup bugs wouldn't surface in Curator tests. The system wouldn't dogfood its own primitive. Curator-on-self collapses these into one path.

The obvious objections — that filename determinism matters at setup, and that setup failing on a Curator bug is bad — are addressed by interview-mode. Determinism comes from the question-key slug. Bypassing the confidence gate works because the source is high-trust. And Curator bugs surfacing at setup are a feature: they catch issues before users hit them in runtime.

A hybrid (static for unambiguous answers, Curator for ambiguous) was rejected because it introduces a meta-rule about which path to take. The meta-rule itself is technical debt at the architecture layer.

Curator gains an explicit mode parameter, `interview` vs `runtime`. The mode controls confidence gating and naming policy; everything else (Entry shape, Archive contract, marker file write) is identical. Phase 2 generation code loops over interview answers and calls Curator; aos carries no separate routing recipe. Curator must be solid before C-narrow ships — setup is its first test, marked P0 on the test plan. The anchor-workflow answer (Q6) generates an Entry; the workflow skill itself is generated separately under `.claude/skills/[anchor].md` as in v1.

## Phase 2 file inventory

When `/aos` runs on a fresh repo with no existing `.claude/`, it creates:

```text
<repo>/
├── CLAUDE.md                  generated from interview — mentions Curator/Janitor, 2 scopes
├── SOUL.md                    v1 carry-over
├── .gitignore                 adds marker files, _archive/, janitor-report-*.md
├── AIOS-README.md             Phase 3 doc — v2 patterns
├── demo-prompts.md            Phase 3 — Curator/Janitor test prompts
└── .claude/
    ├── aos-version            "2.0.0"
    ├── active-context.md      Tracker (was in memory/ in v1)
    ├── memory/
    │   ├── MEMORY.md          index file
    │   └── [Entries seeded via Curator interview-mode from interview answers]
    ├── skills/
    │   ├── curator.md         memory ecosystem
    │   ├── janitor.md         memory ecosystem
    │   └── [anchor].md        v1 carry-over, dynamic name
    ├── agents/
    │   ├── [team]-senior.md   v1 carry-over, dynamic name
    │   └── research-analyst.md
    ├── rules/
    │   ├── brand-voice.md
    │   ├── [primary]-rules.md
    │   └── [secondary]-rules.md
    ├── hooks/
    │   ├── memory-stop.sh     warn-only (ADR-0005)
    │   ├── janitor-surface.sh SessionStart hook
    │   └── janitor-delta.sh   helper
    └── settings.json          registers Stop + SessionStart
```

User Memory at `~/.claude/projects/<repo-hash>/memory/` is not created by aos — the Anthropic harness creates it lazily when Curator first writes a `scope: personal` Entry. aos must not assume it exists.

Tech vs Non-Tech variant: only `memory-stop.sh` differs (Tech adds the secret scan and `.env` guard); all other files are identical.
