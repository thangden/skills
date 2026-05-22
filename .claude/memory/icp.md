---
name: icp
description: Ideal consumer profile for skills shipped from this repo
type: project
scope: team
---

**Primary consumer**: Developers (any team type — Tech, Non-Tech, Product) who want to bootstrap a Claude Code workspace with the 5-layer Agentic OS pattern by running `/aos`. They expect:

- A working skill with clear `SKILL.md` description that triggers reliably
- Predictable Phase 0 → Phase 3 flow that does not surprise on existing `.claude/` content
- Hooks that warn rather than block (no anti-pattern circumvention)
- ADRs accessible to understand design before changing it

**Secondary consumer**: Future contributors to this repo. They read `aos/CONTEXT.md` (glossary) and `aos/docs/adr/` (decisions) before modifying.

**Not in ICP**: Ahamove-internal workshop participants. Workshop is over; this repo is now public skill development only.
