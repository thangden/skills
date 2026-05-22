---
description: Writing style and tone for all source files in this workspace — loaded globally
---

# Brand Voice — Public Skills Development

## Language

- English primary for source files (CLAUDE.md, SKILL.md, ADRs, hooks, README.md)
- Vietnamese acceptable for rationale prose in interview notes or ADR `Why` sections when nuance matters
- Technical terms in English regardless of surrounding language: skill, agent, hook, memory, scope, entry, curator, janitor, archive, marker, tracker

## Sentence shape

- Short. Direct. Cut filler.
- Numbers over adjectives. "40% smaller" beats "much smaller".
- One sentence per update beats one paragraph of throat-clearing.
- Active voice over passive.

## Forbidden patterns

- Marketing language: "revolutionary", "powerful", "delightful", "blazing fast", "world-class"
- Hedging without reason: "perhaps", "maybe", "it seems"
- Throat-clearing: "I think", "In my opinion", "It's worth noting"
- Emoji in source files — only in conversational reply when explicitly requested
- Fantasy or pop-culture metaphors (Hogwarts, One Piece, etc.) — anchor to the actual mechanism

## Acceptable hedging

When flagging genuine uncertainty: "Not yet verified", "Unconfirmed — needs <action>", "Tradeoff: <X> vs <Y>".

## Format defaults

- Markdown H2/H3 (no H1 in middle of doc, only one H1 = the title)
- Bullet lists ≤7 items per group
- Tables for comparison data
- File references as `[name](relative/path)` for IDE clickability
- Code blocks with language tag
- Inline code for filenames, commands, identifiers
