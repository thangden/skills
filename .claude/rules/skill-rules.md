---
description: Rules for authoring SKILL.md files — loaded when working on skill source
paths: ["**/SKILL.md", ".claude/skills/**/*.md", "aos/**/*.md"]
---

# Skill Authoring Rules

## Frontmatter

Required fields:

- `name`: kebab-case identifier matching the filename slug
- `description`: one paragraph, dense, lists trigger conditions explicitly. Used by Claude to decide invocation. This is the single most important field.

Optional fields:

- `model`: `sonnet` | `haiku` | `opus` (default inherits)
- `tools`: array of tool names to restrict (e.g. `[Read, Grep, Glob]` for read-only skills)

## Description writing

The `description` is read by Claude in every turn to decide whether to invoke. Optimize for:

- **Concrete cue phrases** users would say (`"setup workspace"`, `"ghi nhớ"`, `"remember"`)
- **Negative examples** when relevant (`"do not use for X"`)
- **Outcome** described, not just inputs

Bad: `"A skill for memory management."`
Good: `"Routes user-provided info into the correct Memory location with the correct Scope and Type. Triggered implicitly when user signals a save ('ghi nhớ', 'remember', 'from now on') and explicitly via @curator or /curate."`

## Body structure

1. **When to trigger** — explicit cues + content-shape signals + negative examples
2. **Procedure** — numbered steps, each deterministic
3. **Side effects** — what files are written, what markers are touched, what is logged
4. **Edge cases** — conflict, ambiguity, reversal
5. **What this skill does NOT do** — explicit boundaries

## Authority

Skills that implement an ADR-governed behavior must cite the ADR by path at the top of the body. Drift between the ADR and the skill is a bug — flag in code review.

## Length

Aim for under 250 lines. If longer, consider splitting into a helper skill or moving prose to a reference doc the skill links to. SKILL.md is read every turn — keep it tight.

## Testing

Before shipping a skill change, dogfood on this workspace. If the skill is for aos itself, also run `/aos --upgrade` (or fresh-generation) on a test workspace.
