# Active Context — Sprint Tracker

Mutable sprint state. Not a Memory Entry — lives outside `.claude/memory/` per [ADR-0002](../aos/docs/adr/0002-entry-schema-and-tracker-separation.md). Edit items in this list directly.

## In Progress

- [ ] Rewrite `aos/SKILL.md` to v2 per ADR-0001 through ADR-0007
- [ ] Implement Curator skill (`aos/skills/curator.md` template — canonical for aos generation)
- [ ] Implement Janitor skill (`aos/skills/janitor.md` template — canonical for aos generation)
- [ ] Implement migration script per ADR-0007 (`aos --upgrade` + `aos --rollback`)

## To Do

- [ ] Hook scripts: `memory-stop.sh`, `janitor-surface.sh`, `janitor-delta.sh` per ADR-0005
- [ ] Test plan: setup fresh workspace via aos v2, verify Curator routing, Janitor delta
- [ ] Migrate this skills-repo's own `.claude/` to v2 shape after aos v2 implementation lands (currently hand-crafted from ADRs)
- [ ] Push thangden/skills first public release of aos v2 (tag `v2.0.0`)
- [ ] Write C-broad deferred ADRs when ready: User Global Memory loader, Promoter sanitization, plugin marketplace packaging

## Done

- [x] Grill session: 7 ADRs locked (2026-05-22) — see `aos/docs/adr/`
- [x] Glossary locked: `aos/CONTEXT.md` with 17 terms
- [x] Workshop content archived to `/Users/thangden/Dev/tmp/yes-aido-workshop/`
- [x] skills-repo Kernel rewritten (CLAUDE.md + SOUL.md) for public skill-dev focus
- [x] aos v2 workspace bootstrap (this file, .claude/memory/, hooks) — hand-crafted from ADR specs

_Last updated: 2026-05-22_
