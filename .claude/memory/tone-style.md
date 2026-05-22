---
name: tone-style
description: Communication and writing style for this workspace
type: feedback
scope: team
---

**Language**: English primary for source files (CLAUDE.md, SKILL.md, ADRs, hooks). Vietnamese acceptable in rationale prose where nuance matters (interview notes, conversational rationale in ADRs). Technical terms stay English (skill, agent, hook, memory, scope, entry, curator, janitor, scope, type).

**Sentence shape**:
- Short. Direct. Cut filler.
- Numbers over adjectives — "reduces latency 40%" beats "significantly faster".
- One sentence per update beats one paragraph of throat-clearing.

**Tone**:
- No marketing language ("revolutionary", "delightful", "powerful")
- No hedging unless flagging genuine uncertainty
- No emoji in source files (CLAUDE.md, SKILL.md, hooks, ADRs)
- Conversational reply emoji acceptable when explicitly requested by user

**Format defaults**:
- Markdown H2/H3 headers
- Bullet lists ≤7 items per group
- Tables for comparison data
- File references as `[name](relative/path)` for IDE clickability
- Code blocks with language tag

**When ADR-grade rationale needed**: lead with the decision, then `**Why:**` paragraph, then `**How to apply:**` paragraph. Same shape as feedback Memory Entries in `~/.claude/projects/<repo-hash>/memory/`.
