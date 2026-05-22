---
description: Rules for writing ADRs — loaded when working inside aos/docs/adr/
paths: ["aos/docs/adr/**", "**/docs/adr/**"]
---

# ADR Rules

## Gate before writing

An ADR is justified only when all three are true:

1. **Hard to reverse** — undoing the decision later costs meaningful effort
2. **Surprising without context** — a future reader will wonder "why this way?"
3. **Real trade-off** — there were genuine alternatives picked against for specific reasons

If any fails, do not write an ADR. Capture the decision in a commit message or a CONTEXT.md note instead.

## Numbering

Sequential, 4-digit prefix. Scan `aos/docs/adr/` for the highest existing `NNNN-` and increment. Slug in kebab-case.

## Required structure

```markdown
# NNNN — <Title>

**Context.** <1-3 sentences: situation + decision space>

**Decision.** <The chosen path, concrete and unambiguous>

**Why.** <Reasoning anchored in trade-offs>

**Considered options.**
- α <option> — rejected: <reason>
- β <option> — chosen.
- γ <option> — rejected: <reason>

**Consequences.**
- <concrete downstream effect>
```

## Optional sections (only if they add value)

- `Status` (proposed | accepted | deprecated | superseded by NNNN)
- Extended `Considered Options` with full breakdown when rejected alternatives are important to remember
- `Migration Notes` when the decision implies a transition path

## Cross-references

- ADRs cite each other by full title (e.g. "see ADR-0003")
- ADRs may reference `aos/CONTEXT.md` glossary terms by bold
- New terminology introduced in an ADR must also land in `aos/CONTEXT.md`

## Style

- Plain markdown, no frontmatter
- One ADR = one decision; never bundle
- Length: 1 paragraph minimum, ~1 page maximum (~80 lines)
- Past tense for the decision once made, present tense for consequences
