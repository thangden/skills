# thangden/skills

A collection of public Claude Code skills.

The current set is small and focused. Each skill is small, composable, and designed to be hacked on. Skills work with any Claude model.

## Quickstart

```bash
npx skills@latest add thangden/skills
```

Pick the skills you want when prompted. Then run them in Claude Code.

**Update to the latest version:**

```bash
npx skills add thangden/skills --skill aos -y
```

Re-adding pulls the newest content from `main`. (`npx skills update` can under-report changes on public repos — see vercel-labs/skills#484 — so prefer re-`add`.)

## Skills

### `setup/`

- [aos](skills/setup/aos/SKILL.md) — Bootstrap a 5-layer Agentic OS workspace (Kernel, Memory, Rules, Hooks, Agents+Skills) for any team — Tech or Non-Tech. **v2.2** adds `make check`, **cold-start** + **clean-state** gates, and gated OTel observability. **v2.1** added a language-agnostic **verify-gate** (compile / lint / test on Stop, configurable block·warn·off via `config.env`), a **feature-list** work-unit primitive + `feature-evaluator`, and tool-scoped Curator/Janitor. Supports `/aos` (fresh setup or fill-gaps), `/aos --upgrade` (migrate v1 → v2.x with backup), `/aos --rollback` (restore from backup).

## Why these skills exist

Building real applications is hard. Frameworks that try to own the entire process tend to take away control and make bugs in the process hard to resolve.

These skills aim for the opposite: small, easy to adapt, easy to compose. Read the SKILL.md, read the ADRs in `docs/adr/`, then change what doesn't fit your workflow. They are starting points, not religions.

## Repo layout

```text
thangden/skills/
├── .claude-plugin/plugin.json     manifest — lists shipped skills
├── docs/adr/                      repo-wide architecture decisions
├── scripts/
│   ├── link-skills.sh             symlink shipped skills into ~/.claude/skills/
│   └── list-skills.sh             list every SKILL.md in the repo
├── skills/
│   └── setup/                     bucket: bootstrap / configuration skills
│       └── aos/                   skill: Agentic OS Setup
│           ├── SKILL.md
│           ├── CONTEXT.md         skill-specific glossary
│           ├── docs/adr/          skill-specific ADRs
│           ├── templates/         files this skill copies into target workspace
│           └── migrations/        version migration playbooks
├── CLAUDE.md                      repo conventions
├── CONTEXT.md                     repo-wide glossary
├── SOUL.md                        runtime policies + red lines
├── LICENSE
└── README.md
```

## Conventions

- Each shipped skill lives at `skills/<bucket>/<name>/SKILL.md`.
- Every shipped skill appears in `.claude-plugin/plugin.json` AND this README.
- Skills under `personal/`, `in-progress/`, `deprecated/` are local-only — not shipped, not in the manifest, not in this README.
- Architecture decisions belong in `docs/adr/` (skill-specific decisions live in the skill's own `docs/adr/`).

## Develop locally

```bash
git clone https://github.com/thangden/skills
cd skills
./scripts/link-skills.sh          # symlink into ~/.claude/skills/
./scripts/list-skills.sh          # list every SKILL.md
```

The maintainer's dogfood workspace at `.claude/` is git-ignored — it is the place to test shipped skills in real use, never the place to commit team-specific or personal content.

## License

[MIT](LICENSE).
