# thangden/skills

Personal agent skill directory for Claude Code.

## Skills

### `aos` — Agentic OS Setup

Bootstrap a complete 5-layer AI OS (Kernel → Memory → Rules → Hooks → Agents) for any team or workspace — tech or non-tech — via a smart interview that scans context and skips questions it already knows.

**Features:**
- Context-Aware Scan: reads README, package.json, CLAUDE.md to infer team/stack before asking
- Detection Gate: detects existing `.claude/` setup and offers A/B choice (overwrite vs. fill gaps)
- Dynamic Interview: only asks what it doesn't already know
- Generates 15 files across 5 layers, plus `AIOS-README.md` and `demo-prompts.md`

**Works for:** BD, MKT, OPS, Product, Tech FE, Tech BE — any team type.

```bash
npx skills@latest add thangden/skills/aos
```

Then run `/aos` in Claude Code.

---

## Install any skill

```bash
npx skills@latest add thangden/skills/<skill-name>
```
