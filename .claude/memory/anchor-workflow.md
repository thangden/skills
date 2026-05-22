---
name: anchor-workflow
description: The design → ship loop for skills developed in this workspace
type: project
scope: team
---

**Workflow** (input → output):

1. **Brainstorm** — identify a real friction users hit; sketch a skill name + one-line description
2. **Grill** — use `/grill-with-docs` or `/grill-me` to walk the design tree; resolve dependencies one at a time
3. **ADR** — for each hard-to-reverse + surprising + real-trade-off decision, write an ADR in the skill's `docs/adr/` folder
4. **CONTEXT** — lock terminology in the skill's `CONTEXT.md` as decisions crystallize
5. **Implement** — write `SKILL.md` referencing the ADRs; write any helper templates, hooks, scripts
6. **Test** — dogfood on this workspace first; surface bugs before public users hit them
7. **Ship** — commit, push `thangden/skills`, tag with semver (e.g. `aos-v2.0.0`)
8. **Iterate** — collect feedback; new ADR for any rework

**Currently in flight**: aos v2 (steps 1-3 complete: 7 ADRs locked; step 5 starting — `aos/SKILL.md` rewrite).
