# thangden/skills

A collection of public Claude Code skills. The first shipped skill is `aos` (Agentic OS Setup) under `skills/setup/`. Future skills are added as siblings under their appropriate bucket.

## Language

**Skill**:
A unit of shipped behavior loaded by Claude Code — a folder under `skills/<bucket>/<name>/` containing a `SKILL.md` plus any supporting templates or scripts. Identified by the `name` field in its frontmatter.
_Avoid_: "command", "plugin" (a plugin is the whole bundle, not a single skill), "module"

**Bucket**:
A top-level grouping of related skills under `skills/`. Current buckets: `setup/`. Reserved for future use: `engineering/`, `productivity/`, `misc/` (shipped); `personal/`, `in-progress/`, `deprecated/` (not shipped).
_Avoid_: "category", "namespace"

**Plugin manifest**:
The file at `.claude-plugin/plugin.json` that declares which skills this repo ships. Read by `npx skills@latest add` and by Claude Code plugin loaders.
_Avoid_: "manifest" alone (overloaded), "config"

**Shipped skill**:
A skill listed in both `.claude-plugin/plugin.json` and the top-level `README.md`. Lives under `setup/`, `engineering/`, `productivity/`, or `misc/`. Contrasts with **draft** or **private** skills under `in-progress/`, `personal/`, or `deprecated/`.
_Avoid_: "released skill", "stable skill"

**Dogfood workspace**:
The maintainer's own `.claude/` directory at repo root. Used to develop and test the shipped skills against real usage. Git-ignored — never committed to the public repo.
_Avoid_: "test workspace", "local config"

## Relationships

- A **Plugin manifest** lists every **Shipped skill** by relative path
- A **Bucket** groups multiple **Skills**; only certain buckets carry **Shipped skills**
- A **Shipped skill** must appear in the **Plugin manifest** AND the top-level README
- The **Dogfood workspace** is never tracked by git

## Example dialogue

> **Dev:** "I added a new skill — what do I need to update?"
> **Reviewer:** "Three places. Put it under `skills/<bucket>/<name>/`, add it to `.claude-plugin/plugin.json`, and link it from the top-level `README.md`. If it's not ready, drop it in `skills/in-progress/` instead and skip the manifest and README — they list shipped skills only."

## Flagged ambiguities

- "skill" vs "plugin" — resolved: a **Skill** is one folder; the **Plugin** is the whole repo as Claude Code sees it. The **Plugin manifest** lists Skills.
- "config" — too overloaded; use **Plugin manifest** for `plugin.json`, "settings" for hook-level `.claude/settings.json` that aos *generates*, and "domain doc" for skill-specific docs.
