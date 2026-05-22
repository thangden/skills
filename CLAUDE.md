# CLAUDE.md — Public Skills Development Workspace

## Mission

This workspace develops and ships public Claude Code skills, published at [github.com/thangden/skills](https://github.com/thangden/skills). The primary skill in active development is **aos** (Agentic OS Setup), with future skills as siblings.

This workspace **dogfoods aos v2** — it is itself an aos v2 workspace (see `aos/CONTEXT.md` + `aos/docs/adr/0001-0007`). The `.claude/` layout, Curator/Janitor skills, hook scripts, and Memory routing here are the same patterns aos generates for end users.

## ICP — who consumes the output

- **Developers installing skills** from `thangden/skills` via Claude Code plugin marketplace or direct clone. They expect: clear `SKILL.md`, working hooks, predictable behavior, ADRs to understand design.
- **Future contributors** (currently solo) reading `aos/CONTEXT.md` and `aos/docs/adr/` to understand decisions before changing them.

## Golden Rules

1. **Architecture decisions go to ADRs.** Any change to `aos/SKILL.md` that affects Curator routing, Memory schema, Hook contract, or Migration must reference an ADR (existing or new). Don't rewrite design in commit messages.
2. **Dogfood before ship.** Every aos v2 change applies to this workspace first. If it breaks here, it ships broken.
3. **Public repo discipline.** No customer data, no Ahamove-internal docs, no secrets. Workshop content lives in a separate archive — never re-introduce it here.

## Default Output Format

- Markdown headers (## H2 + ### H3)
- Bullet list ≤7 items per group
- File path as `[name](relative/path)` (clickable in IDE)
- Code block with language tag
- ADRs follow `aos/docs/adr/ADR-FORMAT.md`; glossary changes follow `aos/CONTEXT.md` rules

## Tone

- English primary (public-facing repo)
- Vietnamese acceptable in CONTEXT/ADR rationale when nuance helps; technical decisions in English
- Tech terms kept English (skill, agent, hook, memory, scope, entry, curator, janitor)
- Short sentences. Numbers over adjectives.
- No emojis, no marketing language

## Skill Routing

Project-level skills at `.claude/skills/` take priority over global skills. C-narrow ships:

- `.claude/skills/curator.md` — Memory ecosystem (routes Entries by Scope + Type)
- `.claude/skills/janitor.md` — Memory ecosystem (scans + report-with-apply)

## Agent Routing

Project-level agents at `.claude/agents/` take priority over global agents. Skill-dev focused:

- `@skill-reviewer` — review SKILL.md for triggering accuracy + clarity
- `@adr-writer` — help draft ADRs in the format used here
- `@research-analyst` — read-only research specialist (carried from aos v1)

## Memory Layer

Two Scopes in C-narrow (per [ADR-0001](aos/docs/adr/0001-memory-scope-routing.md)):

- `scope: team` → `.claude/memory/` (git-committed, shared with anyone cloning)
- `scope: personal` → `~/.claude/projects/<repo-hash>/memory/` (Anthropic-managed, your machine only)

Curator defaults to `team`. Use `personal` for individual preferences not relevant to other contributors.

## Source of Truth

- Architecture: [aos/CONTEXT.md](aos/CONTEXT.md) + [aos/docs/adr/](aos/docs/adr/)
- Sprint state: [.claude/active-context.md](.claude/active-context.md)
- Working knowledge: [.claude/memory/MEMORY.md](.claude/memory/MEMORY.md)

## Operating Constraints

- One session = one goal (one ADR, one SKILL.md section, one migration step). `/compact` when context > 60%.
- Memory Guard hook warns on missing updates; never blocks except on schema validation failure (per [ADR-0005](aos/docs/adr/0005-hook-architecture.md)).
- Janitor delta runs auto on Stop when Curator was active this session (per [ADR-0004](aos/docs/adr/0004-janitor-trigger-and-action.md)); review `.claude/janitor-report-*.md` next session.
- Do not push to `thangden/skills` without verifying no workshop-private content slipped in.
