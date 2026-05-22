# thangden/skills

Public Claude Code skill directory. Primary skill in active development: **aos** (Agentic OS Setup).

## Skills

### `aos` — Agentic OS Setup

Bootstrap a complete 5-layer Agentic OS workspace (Kernel → Memory → Rules → Hooks → Agents) for any team — Tech or Non-Tech — via a smart interview that scans context first and only asks what it cannot already infer.

**v2 highlights** (see [aos/docs/adr/](aos/docs/adr/) for full design):

- **2-tier Memory Scope** — `team` (git-committed Workspace Memory) + `personal` (Anthropic-managed User Memory)
- **Anthropic 4-type Entry schema** uniform across both scopes
- **Tracker** (`active-context.md`) separated out of Memory — sprint state is not knowledge
- **Curator** skill — hybrid implicit + explicit trigger, confidence-driven routing
- **Janitor** skill — manual full scan + auto-delta on Stop, report-with-batch-apply, archive-not-delete
- **Hook architecture** — Stop + SessionStart, warn-only, schema-validation as the single hard-error path
- **Migration v1 → v2** — explicit `/aos --upgrade` with backup folder, reversible via `/aos --rollback`

**Works for:** BD, MKT, OPS, Product, Tech FE, Tech BE — any team type.

```bash
npx skills@latest add thangden/skills/aos
```

Then run `/aos` in Claude Code.

## Install any skill

```bash
npx skills@latest add thangden/skills/<skill-name>
```

## Repo structure

This repo dogfoods aos v2 — its own `.claude/`, CLAUDE.md, and SOUL.md are themselves an aos v2 workspace.

```text
thangden/skills/
├── CLAUDE.md           Kernel — public skills dev mission
├── SOUL.md             Runtime policies + red lines
├── .claude/            aos v2 workspace (dogfood)
│   ├── aos-version     2.0.0
│   ├── active-context.md   Tracker (sprint state)
│   ├── memory/         Workspace Memory (scope=team Entries)
│   ├── skills/         curator.md + janitor.md
│   ├── agents/         skill-reviewer, adr-writer, research-analyst
│   ├── rules/          brand-voice, adr-rules, skill-rules
│   ├── hooks/          memory-stop.sh, janitor-surface.sh, janitor-delta.sh
│   └── settings.json
└── aos/                the aos skill being developed
    ├── SKILL.md        skill body (v2 rewrite in progress)
    ├── CONTEXT.md      glossary (17 terms locked)
    └── docs/adr/       7 ADRs locking v2 architecture
```

## Contributing

Architecture decisions go through ADRs in [aos/docs/adr/](aos/docs/adr/). Terminology lives in [aos/CONTEXT.md](aos/CONTEXT.md). Read both before proposing changes.
