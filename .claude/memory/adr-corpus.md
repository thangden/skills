---
name: adr-corpus
description: Pointer to the 7 ADRs that lock aos v2 architecture
type: reference
scope: team
---

aos v2 architecture is locked in [aos/docs/adr/](../../aos/docs/adr/). Read in order before changing any related code:

- [0001 — Memory Scope Routing](../../aos/docs/adr/0001-memory-scope-routing.md) — 2-tier Scope (`team` / `personal`) in C-narrow; `global` deferred to C-broad
- [0002 — Entry Schema + Tracker Separation](../../aos/docs/adr/0002-entry-schema-and-tracker-separation.md) — Anthropic 4-type uniform; Tracker out of Memory
- [0003 — Curator Trigger + Routing](../../aos/docs/adr/0003-curator-trigger-and-routing.md) — Hybrid trigger + confidence 0.8
- [0004 — Janitor Trigger + Action](../../aos/docs/adr/0004-janitor-trigger-and-action.md) — Manual + auto-delta-on-Stop + `--apply`
- [0005 — Hook Architecture](../../aos/docs/adr/0005-hook-architecture.md) — Stop + SessionStart, warn-only
- [0006 — Curator-on-Self Seed](../../aos/docs/adr/0006-curator-on-self-seed.md) — Phase 2 dogfoods Curator interview-mode
- [0007 — Migration v1→v2](../../aos/docs/adr/0007-migration-v1-to-v2.md) — Explicit `/aos --upgrade` + backup folder

**Glossary**: [aos/CONTEXT.md](../../aos/CONTEXT.md) — 17 terms locked.

**C-broad deferred ADRs (not yet written)**: User Global Memory loader, Promoter sanitization, plugin marketplace packaging. Numbers assigned when written.
